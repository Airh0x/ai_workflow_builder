import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ai_workflow_builder/env/env.dart';
import 'package:ai_workflow_builder/utils/app_constants.dart';

class GeminiApiService {
  // Singleton pattern
  static final GeminiApiService _instance = GeminiApiService._internal();
  factory GeminiApiService() => _instance;

  GenerativeModel? _generativeModel;
  String? _currentModel;
  final String _apiKey;

  GeminiApiService._internal()
      : _apiKey = Env.geminiApiKey {
    if (_apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('❌ ${AppConstants.errorGeminiApiKeyNotFound}');
      }
      throw Exception(AppConstants.errorGeminiApiKeyNotFound);
    }
  }

  /// モデルを初期化または更新します
  void _initializeModel(String modelName) {
    if (_currentModel == modelName && _generativeModel != null) {
      return; // 既に同じモデルが初期化されている
    }

    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
    ];

    _generativeModel = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(temperature: 0.0),
      safetySettings: safetySettings,
    );
    _currentModel = modelName;
  }

  /// モデル名を指定してモデルを初期化します
  void initializeWithModel(String modelName) {
    _initializeModel(modelName);
  }

  /// プロンプトと画像（XFile）からテキストを生成します。
  Future<String> generateContent(
    String prompt,
    List<XFile> images, {
    String? modelName,
  }) async {
    try {
      // モデル名が指定された場合、またはモデルが初期化されていない場合は初期化
      if (modelName != null) {
        initializeWithModel(modelName);
      } else if (_generativeModel == null) {
        // モデル名が指定されていない場合はデフォルトモデルを使用
        _initializeModel('gemini-3-pro-preview');
      }

      final content = <Content>[];

      // プロンプトを追加
      content.add(Content.text(prompt));

      // 画像データを読み込み、DataPartに変換して追加
      for (final image in images) {
        final Uint8List bytes = await image.readAsBytes();
        content.add(Content.data('image/jpeg', bytes));
      }

      final response = await _generativeModel!.generateContent(content);

      if (response.text != null) {
        return response.text!;
      } else {
        throw Exception('APIからのレスポンスにテキストが含まれていませんでした。');
      }
    } catch (e) {
      // エラーログを出力し、再度スローして呼び出し元で処理できるようにする
      debugPrint('コンテンツ生成中にエラーが発生しました: $e');
      rethrow;
    }
  }
}
