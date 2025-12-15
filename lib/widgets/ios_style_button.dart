import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';

/// HIG準拠のiOSスタイルボタン
/// 
/// Apple Human Interface Guidelinesに準拠した
/// ボタンコンポーネントです。
class IOSStyleButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final IOSButtonStyle style;
  final bool isLoading;
  final String? semanticLabel;

  const IOSStyleButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.style = IOSButtonStyle.primary,
    this.isLoading = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color textColor;
    Color? iconColor;

    switch (style) {
      case IOSButtonStyle.primary:
        backgroundColor = isEnabled
            ? CupertinoColors.systemBlue
            : CupertinoColors.systemGrey4;
        textColor = CupertinoColors.white;
        iconColor = CupertinoColors.white;
        break;
      case IOSButtonStyle.secondary:
        backgroundColor = isEnabled
            ? CupertinoColors.systemGrey5
            : CupertinoColors.systemGrey6;
        textColor = isEnabled
            ? CupertinoColors.label
            : CupertinoColors.tertiaryLabel;
        iconColor = isEnabled
            ? CupertinoColors.label
            : CupertinoColors.tertiaryLabel;
        break;
      case IOSButtonStyle.tertiary:
        backgroundColor = CupertinoColors.systemGrey6;
        textColor = CupertinoColors.label;
        iconColor = CupertinoColors.label;
        break;
    }

    return Semantics(
      label: semanticLabel ?? text,
      button: true,
      enabled: isEnabled,
      child: SizedBox(
        height: AppTheme.buttonHeightStandard,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isEnabled ? onPressed : null,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            AppTheme.borderRadiusStandard,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingStandard,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: CupertinoActivityIndicator(
                      radius: AppTheme.iconSizeStandard * 0.4,
                      color: textColor,
                    ),
                  )
                else if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      icon,
                      size: AppTheme.iconSizeStandard,
                      color: iconColor,
                    ),
                  ),
                Text(
                  isLoading ? '処理中...' : text,
                  style: AppTheme.body(context).copyWith(
                    fontWeight: AppTheme.fontWeightSemibold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum IOSButtonStyle {
  primary, // ライトブルー（システムブルー）
  secondary, // ライトグレー
  tertiary, // より薄いグレー
}

/// HIG準拠のリストアイテムボタン
/// 
/// CupertinoListTileを使用した、HIG準拠のリストアイテムです。
class IOSListButton extends StatelessWidget {
  final String text;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? semanticLabel;

  const IOSListButton({
    super.key,
    required this.text,
    this.leadingIcon,
    this.onTap,
    this.trailing,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      button: true,
      enabled: onTap != null,
      child: CupertinoListTile(
        title: Text(
          text,
          style: AppTheme.body(context),
        ),
        leading: leadingIcon != null
            ? Icon(
                leadingIcon,
                size: AppTheme.iconSizeStandard,
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

/// HIG準拠のアクションボタン（セクション内のボタン）
/// 
/// セクション内で使用する、HIG準拠のアクションボタンです。
class IOSActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final IOSButtonStyle style;
  final bool isLoading;
  final String? semanticLabel;

  const IOSActionButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.style = IOSButtonStyle.primary,
    this.isLoading = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingCompact,
      ),
      child: IOSStyleButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        style: style,
        isLoading: isLoading,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
