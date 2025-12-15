import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/models/prompt_template.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';
import 'package:ai_workflow_builder/features/workflow/prompt_template_edit_screen.dart';

/// プロンプトテンプレート管理画面
class PromptTemplatesScreen extends ConsumerWidget {
  const PromptTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(promptTemplateProvider);
    final templateNotifier = ref.read(promptTemplateProvider.notifier);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('プロンプトテンプレート'),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppTheme.paddingStandard),
          children: [
            // 新規作成ボタン
            CupertinoButton.filled(
              onPressed: () {
                final newTemplate = PromptTemplate(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: '新しいテンプレート',
                  description: '',
                  content: '',
                );
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => PromptTemplateEditScreen(
                      templateId: newTemplate.id,
                    ),
                  ),
                );
              },
              child: const Text('新規テンプレート'),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // テンプレート一覧
            if (templates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'テンプレートがありません',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CupertinoColors.secondaryLabel),
                ),
              )
            else
              ...templates.map((template) => _TemplateCard(
                    template: template,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => PromptTemplateEditScreen(
                            templateId: template.id,
                          ),
                        ),
                      );
                    },
                    onDelete: () async {
                      final confirmed = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('削除確認'),
                          content: Text('「${template.name}」を削除しますか？'),
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
                        await templateNotifier.deleteTemplate(template.id);
                      }
                    },
                  )),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final PromptTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

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
        title: Text(template.name),
        subtitle: template.description.isNotEmpty
            ? Text(template.description)
            : Text(
                'プレースホルダー: ${template.placeholders.length}個',
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

