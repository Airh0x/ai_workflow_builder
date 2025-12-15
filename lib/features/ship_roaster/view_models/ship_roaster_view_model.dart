import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/env/env.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:ai_workflow_builder/models/local_roster.dart';
import 'package:ai_workflow_builder/services/gemini_api_service.dart';
import 'package:ai_workflow_builder/services/line_messaging_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_workflow_builder/providers/settings_provider.dart';
import 'package:ai_workflow_builder/utils/status_type.dart';
import 'package:ai_workflow_builder/utils/app_constants.dart';
import 'package:ai_workflow_builder/utils/prompt_processor.dart';
import 'dart:convert';

// MARK: - Enums
enum RosterSource { localFile, googleSheet }

// MARK: - State Class
@immutable
class ShipRoasterState {
  final String? masterRosterText;
  final List<XFile> selectedImages;
  final String resultText;
  final List<LocalRoster> savedRosters;
  final String? selectedRosterId;
  final String masterRosterFilename;
  final String statusMessage;
  final StatusType statusType;
  final bool isProcessing;
  final bool isLoadingRoster;
  final RosterSource selectedRosterSource;
  final String selectedSheetName;

  const ShipRoasterState({
    this.masterRosterText,
    this.selectedImages = const [],
    this.resultText = '',
    this.savedRosters = const [],
    this.selectedRosterId,
    this.masterRosterFilename = AppConstants.defaultRosterFilename,
    this.statusMessage = AppConstants.defaultStatusMessage,
    this.statusType = StatusType.info,
    this.isProcessing = false,
    this.isLoadingRoster = false,
    this.selectedRosterSource = RosterSource.localFile,
    this.selectedSheetName = AppConstants.defaultSheetName,
  });

  ShipRoasterState copyWith({
    String? masterRosterText,
    List<XFile>? selectedImages,
    String? resultText,
    List<LocalRoster>? savedRosters,
    String? selectedRosterId,
    String? masterRosterFilename,
    String? statusMessage,
    StatusType? statusType,
    bool? isProcessing,
    bool? isLoadingRoster,
    RosterSource? selectedRosterSource,
    String? selectedSheetName,
    bool clearMasterRoster = false,
    bool clearSelectedRosterId = false,
  }) {
    return ShipRoasterState(
      masterRosterText: clearMasterRoster
          ? null
          : masterRosterText ?? this.masterRosterText,
      selectedImages: selectedImages ?? this.selectedImages,
      resultText: resultText ?? this.resultText,
      savedRosters: savedRosters ?? this.savedRosters,
      selectedRosterId: clearSelectedRosterId
          ? null
          : selectedRosterId ?? this.selectedRosterId,
      masterRosterFilename: masterRosterFilename ?? this.masterRosterFilename,
      statusMessage: statusMessage ?? this.statusMessage,
      statusType: statusType ?? this.statusType,
      isProcessing: isProcessing ?? this.isProcessing,
      isLoadingRoster: isLoadingRoster ?? this.isLoadingRoster,
      selectedRosterSource: selectedRosterSource ?? this.selectedRosterSource,
      selectedSheetName: selectedSheetName ?? this.selectedSheetName,
    );
  }
}

// MARK: - ViewModel (StateNotifier)
class ShipRoasterViewModel extends StateNotifier<ShipRoasterState> {
  ShipRoasterViewModel(this.ref) : super(const ShipRoasterState()) {
    _loadRostersFromPrefs();
  }

  final Ref ref; // RiverpodのRefを保持
  final ImagePicker _picker = ImagePicker();

  // MARK: - Public Methods
  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      state = state.copyWith(
        selectedImages: images,
        statusMessage: AppConstants.successImagesSelected.replaceAll(
          '%d',
          images.length.toString(),
        ),
        statusType: StatusType.success,
      );
    }
  }

  void resetInputs() {
    state = state.copyWith(
      selectedImages: [],
      resultText: '',
      masterRosterText: null,
      clearMasterRoster: true,
      selectedRosterId: null,
      clearSelectedRosterId: true,
      masterRosterFilename: AppConstants.defaultRosterFilename,
      statusMessage: AppConstants.defaultStatusMessage,
      statusType: StatusType.info,
    );
  }

  Future<void> copyResultToClipboard() async {
    if (state.resultText.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: state.resultText));
    state = state.copyWith(
      statusMessage: AppConstants.successCopiedToClipboard,
      statusType: StatusType.success,
    );
  }

  Future<void> shareResult() async {
    if (state.resultText.isEmpty) return;
    // ignore: deprecated_member_use
    await Share.share(state.resultText);
  }

  /// LINE Messaging APIに結果を送信（手動送信）
  Future<void> sendToLine() async {
    if (state.resultText.isEmpty) {
      state = state.copyWith(
        statusMessage: '送信する結果がありません',
        statusType: StatusType.error,
      );
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'LINEに送信中...',
      statusType: StatusType.info,
    );

    try {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      final token = await settingsNotifier.getLineMessagingApiToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(
          statusMessage: 'LINE Messaging APIのトークンが設定されていません',
          statusType: StatusType.error,
        );
        return;
      }

      // メッセージを整形（長すぎる場合は切り詰め）
      final message = _formatLineMessage(state.resultText);

      // グループIDが設定されている場合はグループメッセージを優先
      final groupId = await settingsNotifier.getLineMessagingApiGroupId();
      if (kDebugMode) {
        debugPrint('🔍 LINE送信: グループID = ${groupId ?? "未設定"}');
      }
      bool success;
      String? errorMessage;
      if (groupId != null && groupId.isNotEmpty) {
        // グループメッセージ（グループに送信）
        final result = await LineMessagingApiService.sendGroupMessageWithError(
          channelAccessToken: token,
          groupId: groupId,
          message: message,
        );
        success = result['success'] as bool;
        errorMessage = result['error'] as String?;
      } else {
        // グループIDがない場合は従来の方法を使用
        final useBroadcast = await settingsNotifier
            .isLineMessagingApiUseBroadcast();

        if (useBroadcast) {
          // ブロードキャストメッセージ（友だち登録している全ユーザーに送信）
          success = await LineMessagingApiService.sendBroadcastMessage(
            channelAccessToken: token,
            message: message,
          );
        } else {
          // プッシュメッセージ（特定のユーザーに送信）
          final userId = await settingsNotifier.getLineMessagingApiUserId();
          if (userId == null || userId.isEmpty) {
            // ユーザーIDがない場合はブロードキャストにフォールバック
            success = await LineMessagingApiService.sendBroadcastMessage(
              channelAccessToken: token,
              message: message,
            );
          } else {
            success = await LineMessagingApiService.sendPushMessage(
              channelAccessToken: token,
              userId: userId,
              message: message,
            );
          }
        }
      }

      if (success) {
        state = state.copyWith(
          statusMessage: 'LINEに送信しました',
          statusType: StatusType.success,
        );
      } else {
        state = state.copyWith(
          statusMessage: errorMessage ?? 'LINEへの送信に失敗しました',
          statusType: StatusType.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'LINEへの送信エラー: $e',
        statusType: StatusType.error,
      );
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// LINEメッセージを整形（1000文字以内に収める）
  String _formatLineMessage(String result) {
    const maxLength = 1000;
    if (result.length <= maxLength) {
      return '🚢 明日の乗船関係のお知らせ\n\n$result';
    }
    return '🚢 明日の乗船関係のお知らせ\n\n${result.substring(0, maxLength - 10)}...\n\n(メッセージが長いため一部を省略しました)';
  }

  void updateResultText(String newText) {
    state = state.copyWith(
      resultText: newText,
      statusMessage: '結果が編集されました',
      statusType: StatusType.success,
    );
  }

  Future<void> generateList() async {
    if (state.masterRosterText == null || state.selectedImages.isEmpty) {
      state = state.copyWith(
        statusMessage: AppConstants.errorNoRosterOrImages,
        statusType: StatusType.error,
      );
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      statusMessage: AppConstants.processingCreating,
      statusType: StatusType.info,
    );

    try {
      // プロンプトテンプレートを処理
      final settingsNotifier = ref.read(settingsProvider.notifier);
      final promptKey = ref.read(shipRoasterPromptKeyProvider);

      // 除外リストと追加リストを取得
      final excludedPassengers = await settingsNotifier.getExcludedPassengers();
      final addedPassengers = await settingsNotifier.getAddedPassengers();

      final prompt = await PromptProcessor.processPrompt(
        settingsNotifier,
        promptKey,
        masterRoster: state.masterRosterText,
        sheetName: state.selectedSheetName,
        isBoardingPass: false,
        excludedPassengers: excludedPassengers,
        addedPassengers: addedPassengers,
      );

      // 設定からモデル名を取得
      final modelName = settingsNotifier.getGeminiModel();

      final result = await GeminiApiService().generateContent(
        prompt,
        state.selectedImages,
        modelName: modelName,
      );
      state = state.copyWith(
        resultText: result,
        statusMessage: AppConstants.successListCreated,
        statusType: StatusType.success,
      );
    } catch (e) {
      state = state.copyWith(
        statusMessage: '${AppConstants.errorApiFailed}: $e',
        statusType: StatusType.error,
      );
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  Future<void> fetchRosterFromNetwork() async {
    final rosterApiUrl = Env.rosterApiUrl;
    final rosterApiKey = Env.rosterApiKey;

    if (rosterApiUrl.isEmpty || rosterApiKey.isEmpty) {
      state = state.copyWith(
        statusMessage: AppConstants.errorEnvNotConfigured,
        statusType: StatusType.error,
      );
      return;
    }

    state = state.copyWith(
      isLoadingRoster: true,
      statusMessage: AppConstants.processingFetchingRoster,
      statusType: StatusType.info,
    );

    try {
      final uri = Uri.parse(rosterApiUrl).replace(
        queryParameters: {
          'key': rosterApiKey,
          'sheetName': state.selectedSheetName,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedResponse =
            json.decode(response.body) as Map<String, dynamic>;
        final roster = decodedResponse['roster'] as String?;
        final error = decodedResponse['error'] as String?;

        if (roster != null && roster.isNotEmpty) {
          state = state.copyWith(
            masterRosterText: roster,
            masterRosterFilename: 'オンライン名簿',
            statusMessage: AppConstants.successRosterFetched,
            statusType: StatusType.success,
          );
        } else if (error != null) {
          throw Exception('名簿の取得に失敗: $error');
        } else {
          throw Exception('不明なエラーまたは名簿が空です');
        }
      } else {
        throw Exception('サーバーとの通信に失敗しました (Code: ${response.statusCode})');
      }
    } catch (e) {
      state = state.copyWith(
        statusMessage: '${AppConstants.errorNetworkFailed}: $e',
        statusType: StatusType.error,
      );
    } finally {
      state = state.copyWith(isLoadingRoster: false);
    }
  }

  // MARK: - Roster Management
  void setRosterSource(RosterSource source) {
    // 選択が同じ場合は何もしない
    if (state.selectedRosterSource == source) return;

    state = state.copyWith(
      selectedRosterSource: source,
      // ソースが変更されたら、現在の名簿選択をリセットする
      masterRosterText: null,
      clearMasterRoster: true,
      selectedRosterId: null,
      clearSelectedRosterId: true,
      masterRosterFilename: AppConstants.defaultRosterFilename,
      statusMessage: '名簿の選択方法が変更されました',
      statusType: StatusType.info,
    );
  }

  void selectRosterById(String? rosterId) {
    if (rosterId == null) {
      state = state.copyWith(
        selectedRosterId: null,
        clearSelectedRosterId: true,
        masterRosterText: null,
        clearMasterRoster: true,
        masterRosterFilename: AppConstants.defaultRosterFilename,
      );
      return;
    }

    final selected = state.savedRosters.firstWhere((r) => r.id == rosterId);
    state = state.copyWith(
      selectedRosterId: rosterId,
      masterRosterText: selected.content,
      masterRosterFilename: selected.name,
      statusMessage: '名簿「${selected.name}」を選択しました',
      statusType: StatusType.success,
    );
  }

  Future<void> _loadRostersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rostersJson = prefs.getString(AppConstants.savedRostersKey);
    if (rostersJson != null) {
      state = state.copyWith(savedRosters: LocalRoster.decode(rostersJson));
    }
  }

  Future<void> _saveRostersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String rostersJson = LocalRoster.encode(state.savedRosters);
    await prefs.setString(AppConstants.savedRostersKey, rostersJson);
  }

  void addRoster(LocalRoster roster) {
    // 既に同じIDの名簿が存在する場合は更新、そうでなければ追加
    final existingIndex = state.savedRosters.indexWhere(
      (r) => r.id == roster.id,
    );
    final updatedRosters = existingIndex >= 0
        ? [
            ...state.savedRosters.sublist(0, existingIndex),
            roster,
            ...state.savedRosters.sublist(existingIndex + 1),
          ]
        : [...state.savedRosters, roster];
    state = state.copyWith(savedRosters: updatedRosters);
    _saveRostersToPrefs();
  }

  void deleteRoster(String id) {
    final updatedRosters = state.savedRosters.where((r) => r.id != id).toList();
    state = state.copyWith(savedRosters: updatedRosters);
    _saveRostersToPrefs();
  }

  void setSheetName(String sheetName) {
    state = state.copyWith(selectedSheetName: sheetName);
  }
}

// MARK: - Provider
final shipRoasterViewModelProvider =
    StateNotifierProvider<ShipRoasterViewModel, ShipRoasterState>((ref) {
      return ShipRoasterViewModel(ref);
    });
