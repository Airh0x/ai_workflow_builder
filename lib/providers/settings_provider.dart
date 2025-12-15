import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_workflow_builder/env/env.dart';
import 'package:ai_workflow_builder/services/line_messaging_api_service.dart';

const String _defaultShipRoasterPrompt = """
# 役割
あなたは画像解析とデータ処理を行うAIアシスタントです。提供された画像を分析し、指定されたフォーマットで結果を出力してください。

# 指示
1. 提供された画像を詳細に分析してください
2. マスター名簿（%@）と照合してください
3. 指定されたフォーマットに従って結果を出力してください

# マスター名簿
```
%@
```

# 出力フォーマット例
以下のような形式で結果を出力してください：

## カテゴリA
- 項目1
- 項目2

## カテゴリB
- 項目1
- 項目2

# 注意事項
- 画像に含まれる情報のみを使用してください
- 推測や憶測は避け、事実のみを記載してください
- 指定されたフォーマットを厳密に守ってください
""";
const String _defaultBoardingPassPrompt = """
# 役割
あなたは画像から情報を抽出し、指定されたフォーマットで報告文を作成するAIアシスタントです。

# 指示
提供された画像を分析し、以下の手順に従って報告文を生成してください：
1. 画像から必要な情報を抽出します
2. 抽出した情報を整理します
3. 指定されたフォーマットに従って報告文を作成します

# 日付
処理日: %@

# 出力フォーマット例
以下のような形式で結果を出力してください：

## セクション1
- 項目1: 値1
- 項目2: 値2

## セクション2
- 項目1: 値1
- 項目2: 値2

# 注意事項
- 画像に含まれる情報のみを使用してください
- 読み取れない情報は「不明」と記載してください
- 指定されたフォーマットを厳密に守ってください
""";

const String _shipRoasterPromptKey = "promptTemplate";
const String _boardingPassPromptKey = "boardingPassPrompt";
const String _geminiModelKey = "geminiModel";
const String _excludedPassengersKey = "excludedPassengers";
const String _addedPassengersKey = "addedPassengers";
const String _excludedIslandersKey = "excludedIslanders";
const String _excludedReturneesKey = "excludedReturnees";
const String _addedIslandersKey = "addedIslanders";
const String _addedReturneesKey = "addedReturnees";
const String _lineMessagingApiTokenKey = "lineMessagingApiToken";
const String _lineMessagingApiUserIdKey = "lineMessagingApiUserId";
const String _lineMessagingApiGroupIdKey = "lineMessagingApiGroupId";
const String _lineMessagingApiEnabledKey = "lineMessagingApiEnabled";
const String _lineMessagingApiUseBroadcastKey = "lineMessagingApiUseBroadcast";

// 利用可能なGeminiモデル
const String _defaultGeminiModel = "gemini-3-pro-preview";
const List<String> _availableGeminiModels = [
  "gemini-2.5-pro",
  "gemini-3-pro-preview",
];

class SettingsNotifier extends StateNotifier<Map<String, String>> {
  SettingsNotifier() : super({}) {
    _loadSettings();
  }

  SharedPreferences? _prefs;
  bool _isInitializing = false;

  Future<void> _ensurePrefsInitialized() async {
    if (_prefs != null) return;
    if (_isInitializing) {
      // 既に初期化中の場合、完了を待つ
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return;
    }
    _isInitializing = true;
    try {
      _prefs = await SharedPreferences.getInstance();
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _loadSettings() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final shipRoasterPrompt =
        _prefs!.getString(_shipRoasterPromptKey) ?? _defaultShipRoasterPrompt;
    final boardingPassPrompt =
        _prefs!.getString(_boardingPassPromptKey) ?? _defaultBoardingPassPrompt;
    final geminiModel =
        _prefs!.getString(_geminiModelKey) ?? _defaultGeminiModel;
    state = {
      _shipRoasterPromptKey: shipRoasterPrompt,
      _boardingPassPromptKey: boardingPassPrompt,
      _geminiModelKey: geminiModel,
    };
  }

  Future<void> updatePrompt(String key, String value) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    await _prefs!.setString(key, value);
    state = {...state, key: value};
  }

  String getPrompt(String key) {
    return state[key] ?? '';
  }

  String getDefaultPrompt(String key) {
    if (key == _shipRoasterPromptKey) {
      return _defaultShipRoasterPrompt;
    }
    if (key == _boardingPassPromptKey) {
      return _defaultBoardingPassPrompt;
    }
    return '';
  }

  String getGeminiModel() {
    return state[_geminiModelKey] ?? _defaultGeminiModel;
  }

  Future<void> updateGeminiModel(String model) async {
    if (!_availableGeminiModels.contains(model)) {
      throw ArgumentError('Invalid Gemini model: $model');
    }
    await updatePrompt(_geminiModelKey, model);
  }

  List<String> getAvailableGeminiModels() {
    return List.unmodifiable(_availableGeminiModels);
  }

  String getDefaultGeminiModel() {
    return _defaultGeminiModel;
  }

  // MARK: - Excluded Passengers Management
  Future<List<String>> getExcludedPassengers() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return [];
    final excludedJson = _prefs!.getString(_excludedPassengersKey);
    if (excludedJson == null || excludedJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(excludedJson) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addExcludedPassenger(String name) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    final currentList = await getExcludedPassengers();
    if (currentList.contains(name.trim())) {
      return; // 既に存在する場合は何もしない
    }
    final updatedList = [...currentList, name.trim()];
    final jsonString = json.encode(updatedList);
    await _prefs!.setString(_excludedPassengersKey, jsonString);
  }

  Future<void> removeExcludedPassenger(String name) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    final currentList = await getExcludedPassengers();
    final updatedList = currentList.where((n) => n != name).toList();
    final jsonString = json.encode(updatedList);
    await _prefs!.setString(_excludedPassengersKey, jsonString);
  }

  Future<void> clearExcludedPassengers() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    await _prefs!.remove(_excludedPassengersKey);
  }

  // MARK: - Added Passengers Management
  Future<List<String>> getAddedPassengers() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return [];
    final addedJson = _prefs!.getString(_addedPassengersKey);
    if (addedJson == null || addedJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(addedJson) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addPassenger(String name) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    final currentList = await getAddedPassengers();
    if (currentList.contains(name.trim())) {
      return; // 既に存在する場合は何もしない
    }
    final updatedList = [...currentList, name.trim()];
    final jsonString = json.encode(updatedList);
    await _prefs!.setString(_addedPassengersKey, jsonString);
  }

  Future<void> removeAddedPassenger(String name) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    final currentList = await getAddedPassengers();
    final updatedList = currentList.where((n) => n != name).toList();
    final jsonString = json.encode(updatedList);
    await _prefs!.setString(_addedPassengersKey, jsonString);
  }

  Future<void> clearAddedPassengers() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    await _prefs!.remove(_addedPassengersKey);
  }

  // MARK: - Excluded Islanders and Returnees Management
  Future<List<String>> getExcludedIslanders() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return [];
    final excludedJson = _prefs!.getString(_excludedIslandersKey);
    if (excludedJson == null || excludedJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(excludedJson) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> setExcludedIslanders(List<String> names) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    final jsonString = json.encode(names);
    await _prefs!.setString(_excludedIslandersKey, jsonString);
  }

  Future<List<String>> getExcludedReturnees() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return [];
    final excludedJson = _prefs!.getString(_excludedReturneesKey);
    if (excludedJson == null || excludedJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(excludedJson) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> setExcludedReturnees(List<String> names) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    final jsonString = json.encode(names);
    await _prefs!.setString(_excludedReturneesKey, jsonString);
  }

  // MARK: - Added Islanders and Returnees Management
  Future<List<String>> getAddedIslanders() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return [];
    final addedJson = _prefs!.getString(_addedIslandersKey);
    if (addedJson == null || addedJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(addedJson) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> setAddedIslanders(List<String> names) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    final jsonString = json.encode(names);
    await _prefs!.setString(_addedIslandersKey, jsonString);
  }

  Future<List<String>> getAddedReturnees() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return [];
    final addedJson = _prefs!.getString(_addedReturneesKey);
    if (addedJson == null || addedJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(addedJson) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> setAddedReturnees(List<String> names) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    final jsonString = json.encode(names);
    await _prefs!.setString(_addedReturneesKey, jsonString);
  }

  // MARK: - LINE Messaging API Management
  Future<String?> getLineMessagingApiToken() async {
    // まず.envから読み込む
    try {
      final envToken = Env.lineChannelAccessToken;
      if (envToken.isNotEmpty) {
        return envToken;
      }
    } catch (e) {
      // .envに設定されていない場合は無視
    }

    // .envにない場合はSharedPreferencesから読み込む
    await _ensurePrefsInitialized();
    if (_prefs == null) return null;
    final savedToken = _prefs!.getString(_lineMessagingApiTokenKey);
    if (savedToken != null && savedToken.isNotEmpty) {
      return savedToken;
    }

    // どちらにもない場合は、チャンネルIDとシークレットから自動取得を試みる
    try {
      final channelId = Env.lineChannelId;
      final channelSecret = Env.lineChannelSecret;
      if (channelId.isNotEmpty && channelSecret.isNotEmpty) {
        // チャンネルIDとシークレットからアクセストークンを取得
        final token = await LineMessagingApiService.getAccessToken(
          channelId: channelId,
          channelSecret: channelSecret,
        );
        if (token != null && token.isNotEmpty) {
          // 取得したトークンを保存（次回から使用）
          await setLineMessagingApiToken(token);
          return token;
        }
      }
    } catch (e) {
      // 自動取得に失敗した場合は無視
    }

    return null;
  }

  Future<void> setLineMessagingApiToken(String? token) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    if (token == null || token.isEmpty) {
      await _prefs!.remove(_lineMessagingApiTokenKey);
    } else {
      await _prefs!.setString(_lineMessagingApiTokenKey, token);
    }
  }

  Future<String?> getLineMessagingApiUserId() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return null;
    return _prefs!.getString(_lineMessagingApiUserIdKey);
  }

  Future<void> setLineMessagingApiUserId(String? userId) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    if (userId == null || userId.isEmpty) {
      await _prefs!.remove(_lineMessagingApiUserIdKey);
    } else {
      await _prefs!.setString(_lineMessagingApiUserIdKey, userId);
    }
  }

  Future<bool> isLineMessagingApiEnabled() async {
    // .envにトークンまたはチャンネルID/シークレットがあれば有効
    try {
      final envToken = Env.lineChannelAccessToken;
      if (envToken.isNotEmpty) {
        return true;
      }
      final channelId = Env.lineChannelId;
      final channelSecret = Env.lineChannelSecret;
      if (channelId.isNotEmpty && channelSecret.isNotEmpty) {
        return true;
      }
    } catch (e) {
      // .envに設定されていない場合は無視
    }

    // SharedPreferencesから読み込む
    await _ensurePrefsInitialized();
    if (_prefs == null) return false;
    return _prefs!.getBool(_lineMessagingApiEnabledKey) ?? false;
  }

  Future<void> setLineMessagingApiEnabled(bool enabled) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    await _prefs!.setBool(_lineMessagingApiEnabledKey, enabled);
  }

  Future<bool> isLineMessagingApiUseBroadcast() async {
    // デフォルトはブロードキャスト（ユーザーID不要）
    // SharedPreferencesから読み込む（設定されていない場合はtrue）
    await _ensurePrefsInitialized();
    if (_prefs == null) return true;
    return _prefs!.getBool(_lineMessagingApiUseBroadcastKey) ?? true;
  }

  Future<void> setLineMessagingApiUseBroadcast(bool useBroadcast) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    await _prefs!.setBool(_lineMessagingApiUseBroadcastKey, useBroadcast);
  }

  Future<String?> getLineMessagingApiGroupId() async {
    // まず.envから読み込む
    try {
      final envGroupId = Env.lineGroupId;
      if (envGroupId != null && envGroupId.isNotEmpty) {
        return envGroupId;
      }
    } catch (e) {
      // .envに設定されていない場合は無視
    }

    // .envにない場合はSharedPreferencesから読み込む
    await _ensurePrefsInitialized();
    if (_prefs == null) return null;
    return _prefs!.getString(_lineMessagingApiGroupIdKey);
  }

  Future<void> setLineMessagingApiGroupId(String? groupId) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) {
      throw StateError('SharedPreferences is not initialized');
    }
    if (groupId == null || groupId.isEmpty) {
      await _prefs!.remove(_lineMessagingApiGroupIdKey);
    } else {
      await _prefs!.setString(_lineMessagingApiGroupIdKey, groupId);
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Map<String, String>>((ref) {
      return SettingsNotifier();
    });

// キーを外部から参照できるように公開
final shipRoasterPromptKeyProvider = Provider<String>(
  (_) => _shipRoasterPromptKey,
);
final boardingPassPromptKeyProvider = Provider<String>(
  (_) => _boardingPassPromptKey,
);
final geminiModelKeyProvider = Provider<String>((_) => _geminiModelKey);
