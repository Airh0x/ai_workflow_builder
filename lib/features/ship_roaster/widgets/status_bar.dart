import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';
import 'package:ai_workflow_builder/utils/status_type.dart';

class StatusBar extends StatelessWidget {
  final String message;
  final StatusType type;

  const StatusBar({super.key, required this.message, required this.type});

  IconData get _icon {
    switch (type) {
      case StatusType.info:
        return CupertinoIcons.info;
      case StatusType.success:
        return CupertinoIcons.check_mark_circled_solid;
      case StatusType.error:
        return CupertinoIcons.exclamationmark_circle;
    }
  }

  Color _backgroundColor() {
    switch (type) {
      case StatusType.info:
        return CupertinoColors.systemBlue.withValues(alpha: 0.15);
      case StatusType.success:
        return CupertinoColors.systemGreen.withValues(alpha: 0.15);
      case StatusType.error:
        return CupertinoColors.destructiveRed.withValues(alpha: 0.15);
    }
  }

  Color _foregroundColor() {
    switch (type) {
      case StatusType.info:
        return CupertinoColors.systemBlue;
      case StatusType.success:
        return CupertinoColors.systemGreen;
      case StatusType.error:
        return CupertinoColors.destructiveRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ステータス: $message',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingStandard,
          vertical: AppTheme.paddingStandard * 0.75,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor(),
          border: Border(
            top: BorderSide(
              color: _foregroundColor().withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Icon(
                _icon,
                color: _foregroundColor(),
                size: AppTheme.iconSizeStandard,
              ),
              const SizedBox(width: AppTheme.paddingStandard * 0.75),
              Expanded(
                child: Text(
                  message,
                  style: AppTheme.subheadline(context).copyWith(
                    color: _foregroundColor(),
                    fontWeight: AppTheme.fontWeightSemibold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
