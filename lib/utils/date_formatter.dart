import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  /// 日本時間（JST）で現在の日付を取得
  /// 日付のみを扱うため、時刻は0時に設定
  static DateTime _getTodayJST() {
    final now = DateTime.now();
    // ローカル時間で今日の0時を取得
    return DateTime(now.year, now.month, now.day);
  }

  /// 画像読み取り用の日付フォーマット（今日の3日後）
  static String formatBoardingPassDate() {
    final today = _getTodayJST();
    final targetDate = today.add(const Duration(days: 3));
    return DateFormat('yyyy年MM月dd日').format(targetDate);
  }

  /// 曜日を日本語で取得
  static String _getJapaneseWeekday(DateTime date) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[date.weekday - 1];
  }

  /// データ処理用の日付フォーマット（翌日の日付と曜日）
  /// 形式: [yyyy年MM月dd日(E)]
  /// 処理した日の翌日を表示（今日が15日なら16日を表示）
  static String formatNextDayWithWeekday() {
    final now = DateTime.now();
    // 現在の日付を取得（時刻は無視）
    final today = DateTime(now.year, now.month, now.day);
    // 翌日を計算
    final nextDay = today.add(const Duration(days: 1));
    final weekday = _getJapaneseWeekday(nextDay);
    final formatted =
        '[${DateFormat('yyyy年MM月dd日').format(nextDay)}($weekday)]';

    // デバッグ情報（本番環境では削除可能）
    if (kDebugMode) {
      debugPrint(
        '📅 日付計算: 今日=${now.year}/${now.month}/${now.day}, 翌日=${nextDay.year}/${nextDay.month}/${nextDay.day}',
      );
    }

    return formatted;
  }
}
