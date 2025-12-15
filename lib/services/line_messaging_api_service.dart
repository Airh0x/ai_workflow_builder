import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// LINE Messaging APIを使用してメッセージを送信するサービス
///
/// LINE Notifyの代替として、LINE Messaging APIを使用します。
/// 注意: ユーザーIDが必要です（プッシュメッセージの場合）
class LineMessagingApiService {
  static const String _apiUrl = 'https://api.line.me/v2/bot/message/push';
  static const String _tokenUrl = 'https://api.line.me/v2/oauth/accessToken';

  /// LINE Messaging APIにプッシュメッセージを送信
  ///
  /// [channelAccessToken] LINE Messaging APIのチャネルアクセストークン
  /// [userId] 送信先のユーザーID（LINE公式アカウントの友だち登録が必要）
  /// [message] 送信するメッセージ
  ///
  /// 戻り値: 成功した場合はtrue、失敗した場合はfalse
  static Future<bool> sendPushMessage({
    required String channelAccessToken,
    required String userId,
    required String message,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer $channelAccessToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'to': userId,
              'messages': [
                {'type': 'text', 'text': message},
              ],
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('リクエストがタイムアウトしました');
            },
          );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ LINE Messaging API: メッセージ送信成功');
        }
        return true;
      } else {
        // エラーレスポンスをパースして詳細を表示
        try {
          final errorBody = json.decode(response.body);
          if (kDebugMode) {
            debugPrint('❌ LINE Messaging API: HTTP ${response.statusCode}');
            debugPrint('Error: ${errorBody['message'] ?? response.body}');
            if (errorBody['details'] != null) {
              debugPrint('Details: ${errorBody['details']}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ LINE Messaging API: HTTP ${response.statusCode}');
            debugPrint('Response: ${response.body}');
          }
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LINE Messaging API送信エラー: $e');
      }
      return false;
    }
  }

  /// ブロードキャストメッセージを送信（友だち登録している全ユーザーに送信）
  ///
  /// [channelAccessToken] LINE Messaging APIのチャネルアクセストークン
  /// [message] 送信するメッセージ
  ///
  /// 戻り値: 成功した場合はtrue、失敗した場合はfalse
  static Future<bool> sendBroadcastMessage({
    required String channelAccessToken,
    required String message,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://api.line.me/v2/bot/message/broadcast'),
            headers: {
              'Authorization': 'Bearer $channelAccessToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'messages': [
                {'type': 'text', 'text': message},
              ],
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('リクエストがタイムアウトしました');
            },
          );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ LINE Messaging API: ブロードキャスト送信成功');
        }
        return true;
      } else {
        // エラーレスポンスをパースして詳細を表示
        try {
          final errorBody = json.decode(response.body);
          if (kDebugMode) {
            debugPrint('❌ LINE Messaging API: HTTP ${response.statusCode}');
            debugPrint('Error: ${errorBody['message'] ?? response.body}');
            if (errorBody['details'] != null) {
              debugPrint('Details: ${errorBody['details']}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ LINE Messaging API: HTTP ${response.statusCode}');
            debugPrint('Response: ${response.body}');
          }
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LINE Messaging API送信エラー: $e');
      }
      return false;
    }
  }

  /// チャンネルIDとチャネルシークレットからアクセストークンを取得
  ///
  /// [channelId] LINE Messaging APIのチャネルID
  /// [channelSecret] LINE Messaging APIのチャネルシークレット
  ///
  /// 戻り値: アクセストークン（成功時）、null（失敗時）
  static Future<String?> getAccessToken({
    required String channelId,
    required String channelSecret,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_tokenUrl),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'grant_type': 'client_credentials',
              'client_id': channelId,
              'client_secret': channelSecret,
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('リクエストがタイムアウトしました');
            },
          );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final accessToken = responseBody['access_token'] as String?;
        if (accessToken != null && accessToken.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('✅ LINE Messaging API: アクセストークン取得成功');
          }
          return accessToken;
        }
      }

      if (kDebugMode) {
        debugPrint('❌ LINE Messaging API: アクセストークン取得失敗');
        debugPrint('HTTP ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LINE Messaging API アクセストークン取得エラー: $e');
      }
      return null;
    }
  }

  /// グループメッセージを送信（エラーメッセージ付き）
  ///
  /// [channelAccessToken] LINE Messaging APIのチャネルアクセストークン
  /// [groupId] 送信先のグループID（LINE公式アカウントがグループに参加している必要がある）
  /// [message] 送信するメッセージ
  ///
  /// 戻り値: {'success': bool, 'error': String?} の形式
  static Future<Map<String, dynamic>> sendGroupMessageWithError({
    required String channelAccessToken,
    required String groupId,
    required String message,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 LINEグループメッセージ送信開始');
        debugPrint('グループID: $groupId');
        debugPrint('メッセージ長: ${message.length}文字');
      }
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer $channelAccessToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'to': groupId,
              'messages': [
                {'type': 'text', 'text': message},
              ],
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('リクエストがタイムアウトしました');
            },
          );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ LINE Messaging API: グループメッセージ送信成功');
        }
        return {'success': true, 'error': null};
      } else {
        // エラーレスポンスをパースして詳細を表示
        String errorMsg = 'HTTP ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          final apiMessage = errorBody['message'] as String?;
          if (apiMessage != null) {
            errorMsg = apiMessage;
          }
          if (kDebugMode) {
            debugPrint('❌ LINE Messaging API: HTTP ${response.statusCode}');
            debugPrint('Error: $errorMsg');
            debugPrint('Response: ${response.body}');
            if (errorBody['details'] != null) {
              debugPrint('Details: ${errorBody['details']}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ LINE Messaging API: HTTP ${response.statusCode}');
            debugPrint('Response: ${response.body}');
          }
          errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
        }
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      final errorMsg = '送信エラー: $e';
      if (kDebugMode) {
        debugPrint('❌ LINE Messaging API送信エラー: $e');
      }
      return {'success': false, 'error': errorMsg};
    }
  }

  /// グループメッセージを送信（簡易版）
  ///
  /// [channelAccessToken] LINE Messaging APIのチャネルアクセストークン
  /// [groupId] 送信先のグループID（LINE公式アカウントがグループに参加している必要がある）
  /// [message] 送信するメッセージ
  ///
  /// 戻り値: 成功した場合はtrue、失敗した場合はfalse
  static Future<bool> sendGroupMessage({
    required String channelAccessToken,
    required String groupId,
    required String message,
  }) async {
    final result = await sendGroupMessageWithError(
      channelAccessToken: channelAccessToken,
      groupId: groupId,
      message: message,
    );
    return result['success'] as bool;
  }

  /// チャネルアクセストークンの有効性を確認
  ///
  /// [channelAccessToken] LINE Messaging APIのチャネルアクセストークン
  ///
  /// 戻り値: 有効な場合はtrue、無効な場合はfalse
  static Future<bool> validateToken(String channelAccessToken) async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.line.me/v2/bot/info'),
            headers: {'Authorization': 'Bearer $channelAccessToken'},
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('リクエストがタイムアウトしました');
            },
          );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ LINE Messaging API トークン検証エラー: $e');
      }
      return false;
    }
  }
}
