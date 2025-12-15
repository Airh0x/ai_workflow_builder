import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/models/output_format.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';
import 'package:ai_workflow_builder/features/workflow/output_format_edit_screen.dart';

/// 出力フォーマット管理画面
class OutputFormatsScreen extends ConsumerWidget {
  const OutputFormatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formats = ref.watch(outputFormatProvider);
    final formatNotifier = ref.read(outputFormatProvider.notifier);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('出力フォーマット'),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppTheme.paddingStandard),
          children: [
            // 新規作成ボタン
            CupertinoButton.filled(
              onPressed: () {
                final newFormat = OutputFormat(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: '新しいフォーマット',
                  description: '',
                  template: '',
                  type: OutputType.markdown,
                );
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => OutputFormatEditScreen(
                      formatId: newFormat.id,
                    ),
                  ),
                );
              },
              child: const Text('新規フォーマット'),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // フォーマット一覧
            if (formats.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'フォーマットがありません',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CupertinoColors.secondaryLabel),
                ),
              )
            else
              ...formats.map((format) => _FormatCard(
                    format: format,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => OutputFormatEditScreen(
                            formatId: format.id,
                          ),
                        ),
                      );
                    },
                    onDelete: () async {
                      final confirmed = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('削除確認'),
                          content: Text('「${format.name}」を削除しますか？'),
                          actions: [
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('削除'),
                            ),
                            CupertinoDialogAction(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('キャンセル'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await formatNotifier.deleteFormat(format.id);
                      }
                    },
                  )),
          ],
        ),
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  final OutputFormat format;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FormatCard({
    required this.format,
    required this.onTap,
    required this.onDelete,
  });

  String _getTypeLabel(OutputType type) {
    switch (type) {
      case OutputType.markdown:
        return 'Markdown';
      case OutputType.json:
        return 'JSON';
      case OutputType.csv:
        return 'CSV';
      case OutputType.custom:
        return 'カスタム';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.paddingStandard),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusStandard),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoListTile(
        title: Text(format.name),
        subtitle: format.description.isNotEmpty
            ? Text(format.description)
            : Text(
                'タイプ: ${_getTypeLabel(format.type)}',
                style: const TextStyle(
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onDelete,
          child: const Icon(
            CupertinoIcons.delete,
            color: CupertinoColors.destructiveRed,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

