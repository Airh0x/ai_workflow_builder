import 'package:flutter/cupertino.dart';

/// レスポンシブデザイン用のユーティリティクラス
class ResponsiveDesign {
  ResponsiveDesign._();

  /// 画面サイズに応じたパディングを取得
  static EdgeInsetsGeometry padding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      // タブレット以上
      return EdgeInsets.symmetric(
        horizontal: width * 0.1,
        vertical: 16,
      );
    } else if (width > 400) {
      // 大きめのスマホ
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else {
      // 通常のスマホ
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  /// セクション間のスペーシング
  static double sectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 16;
    } else if (width > 400) {
      return 12;
    } else {
      return 8;
    }
  }

  /// フォントサイズ（タイトル）
  static double titleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 28;
    } else if (width > 400) {
      return 24;
    } else {
      return 20;
    }
  }

  /// フォントサイズ（本文）
  static double bodyFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 19;
    } else if (width > 400) {
      return 18;
    } else {
      return 17;
    }
  }

  /// フォントサイズ（小）
  static double smallFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 15;
    } else if (width > 400) {
      return 14;
    } else {
      return 13;
    }
  }

  /// ボタンの高さ
  static double buttonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 56;
    } else if (width > 400) {
      return 52;
    } else {
      return 48;
    }
  }

  /// アイコンサイズ
  static double iconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 28;
    } else if (width > 400) {
      return 24;
    } else {
      return 20;
    }
  }

  /// 角丸の半径
  static double borderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 16;
    } else if (width > 400) {
      return 14;
    } else {
      return 12;
    }
  }

  /// 最大コンテンツ幅（タブレット以上で中央配置）
  static double? maxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 700;
    }
    return null;
  }
}

