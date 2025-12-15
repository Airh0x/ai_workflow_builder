import 'package:flutter/cupertino.dart';

/// HIG準拠のアプリケーションテーマ
/// 
/// Apple Human Interface Guidelinesに準拠した
/// デザインシステムを提供します。
class AppTheme {
  AppTheme._();

  // MARK: - Spacing (HIG準拠)
  /// 最小タップターゲットサイズ（44pt）
  static const double minTapTarget = 44.0;
  
  /// 標準パディング
  static const double paddingStandard = 16.0;
  
  /// コンパクトパディング
  static const double paddingCompact = 8.0;
  
  /// 拡張パディング
  static const double paddingExtended = 24.0;
  
  /// セクション間のスペーシング
  static const double sectionSpacing = 16.0;
  
  /// リストアイテム間のスペーシング
  static const double listItemSpacing = 8.0;

  // MARK: - Typography (HIG準拠)
  /// 大タイトル（Large Title）
  static const double fontSizeLargeTitle = 34.0;
  
  /// タイトル1（Title 1）
  static const double fontSizeTitle1 = 28.0;
  
  /// タイトル2（Title 2）
  static const double fontSizeTitle2 = 22.0;
  
  /// タイトル3（Title 3）
  static const double fontSizeTitle3 = 20.0;
  
  /// ヘッドライン（Headline）
  static const double fontSizeHeadline = 17.0;
  
  /// 本文（Body）
  static const double fontSizeBody = 17.0;
  
  /// コールアウト（Callout）
  static const double fontSizeCallout = 16.0;
  
  /// サブヘッドライン（Subheadline）
  static const double fontSizeSubheadline = 15.0;
  
  /// フッター（Footnote）
  static const double fontSizeFootnote = 13.0;
  
  /// キャプション1（Caption 1）
  static const double fontSizeCaption1 = 12.0;
  
  /// キャプション2（Caption 2）
  static const double fontSizeCaption2 = 11.0;

  // MARK: - Font Weights
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // MARK: - Border Radius (HIG準拠)
  /// 標準の角丸
  static const double borderRadiusStandard = 10.0;
  
  /// コンパクトな角丸
  static const double borderRadiusCompact = 8.0;
  
  /// 大きな角丸
  static const double borderRadiusLarge = 16.0;

  // MARK: - Icon Sizes (HIG準拠)
  /// 小さいアイコン
  static const double iconSizeSmall = 16.0;
  
  /// 標準アイコン
  static const double iconSizeStandard = 20.0;
  
  /// 大きいアイコン
  static const double iconSizeLarge = 28.0;

  // MARK: - Button Heights (HIG準拠)
  /// 標準ボタンの高さ
  static const double buttonHeightStandard = 44.0;
  
  /// コンパクトボタンの高さ
  static const double buttonHeightCompact = 36.0;
  
  /// 大きなボタンの高さ
  static const double buttonHeightLarge = 50.0;

  // MARK: - Animation Durations (HIG準拠)
  /// 標準アニメーション時間
  static const Duration animationDurationStandard = Duration(milliseconds: 250);
  
  /// 短いアニメーション時間
  static const Duration animationDurationShort = Duration(milliseconds: 150);
  
  /// 長いアニメーション時間
  static const Duration animationDurationLong = Duration(milliseconds: 350);

  // MARK: - Text Styles (HIG準拠)
  static TextStyle largeTitle(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeLargeTitle,
      fontWeight: fontWeightBold,
      letterSpacing: 0.37,
      color: CupertinoColors.label.resolveFrom(context),
    );
  }

  static TextStyle title1(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeTitle1,
      fontWeight: fontWeightBold,
      letterSpacing: 0.36,
      color: CupertinoColors.label.resolveFrom(context),
    );
  }

  static TextStyle title2(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeTitle2,
      fontWeight: fontWeightBold,
      letterSpacing: 0.35,
      color: CupertinoColors.label.resolveFrom(context),
    );
  }

  static TextStyle title3(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeTitle3,
      fontWeight: fontWeightSemibold,
      letterSpacing: 0.38,
      color: CupertinoColors.label.resolveFrom(context),
    );
  }

  static TextStyle headline(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeHeadline,
      fontWeight: fontWeightSemibold,
      letterSpacing: -0.41,
      color: CupertinoColors.label.resolveFrom(context),
    );
  }

  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeBody,
      fontWeight: fontWeightRegular,
      letterSpacing: -0.41,
      color: CupertinoColors.label.resolveFrom(context),
    );
  }

  static TextStyle callout(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeCallout,
      fontWeight: fontWeightRegular,
      letterSpacing: -0.32,
      color: CupertinoColors.label.resolveFrom(context),
    );
  }

  static TextStyle subheadline(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeSubheadline,
      fontWeight: fontWeightRegular,
      letterSpacing: -0.24,
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
    );
  }

  static TextStyle footnote(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeFootnote,
      fontWeight: fontWeightRegular,
      letterSpacing: -0.08,
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
    );
  }

  static TextStyle caption1(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeCaption1,
      fontWeight: fontWeightRegular,
      letterSpacing: 0.0,
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
    );
  }

  static TextStyle caption2(BuildContext context) {
    return TextStyle(
      fontSize: fontSizeCaption2,
      fontWeight: fontWeightRegular,
      letterSpacing: 0.07,
      color: CupertinoColors.tertiaryLabel.resolveFrom(context),
    );
  }
}

