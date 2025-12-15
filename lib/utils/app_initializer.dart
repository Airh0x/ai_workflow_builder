import 'package:flutter/foundation.dart';
import 'package:ai_workflow_builder/env/env.dart';
import 'package:ai_workflow_builder/services/gemini_api_service.dart';
import 'package:ai_workflow_builder/utils/app_constants.dart';

/// アプリケーションの初期化処理を担当するクラス
class AppInitializer {
  AppInitializer._(); // インスタンス化を防ぐ

  /// APIキーの読み込みと検証を行う
  static Future<void> validateApiKeys() async {
    try {
      final geminiApiKey = Env.geminiApiKey;
      final rosterApiUrl = Env.rosterApiUrl;
      final rosterApiKey = Env.rosterApiKey;

      if (kDebugMode) {
        _logApiKeyStatus(geminiApiKey, rosterApiUrl, rosterApiKey);
      }

      // GeminiApiServiceの初期化を試行（エラーがあれば早期に検出）
      try {
        GeminiApiService();
        if (kDebugMode) {
          debugPrint('✅ GeminiApiServiceの初期化に成功しました');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ GeminiApiServiceの初期化に失敗しました: $e');
        }
        // エラーが発生してもアプリは起動する（後でエラーメッセージを表示）
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 環境変数の読み込みに失敗しました: $e');
        debugPrint(AppConstants.hintBuildRunner);
      }
    }
  }

  static void _logApiKeyStatus(
    String geminiApiKey,
    String rosterApiUrl,
    String rosterApiKey,
  ) {
    debugPrint('✅ APIキーの読み込み確認:');
    debugPrint(
      '  - GEMINI_API_KEY: ${geminiApiKey.isNotEmpty ? "設定済み (${geminiApiKey.length}文字)" : "未設定"}',
    );
    debugPrint(
      '  - ROSTER_API_URL: ${rosterApiUrl.isNotEmpty ? "設定済み" : "未設定"}',
    );
    debugPrint(
      '  - ROSTER_API_KEY: ${rosterApiKey.isNotEmpty ? "設定済み (${rosterApiKey.length}文字)" : "未設定"}',
    );
  }
}

