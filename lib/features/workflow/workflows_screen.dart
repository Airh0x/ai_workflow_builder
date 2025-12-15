import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/models/workflow.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';
import 'package:ai_workflow_builder/features/workflow/workflow_edit_screen.dart';

/// ワークフロー管理画面
class WorkflowsScreen extends ConsumerWidget {
  const WorkflowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflows = ref.watch(workflowProvider);
    final workflowNotifier = ref.read(workflowProvider.notifier);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('ワークフロー管理'),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppTheme.paddingStandard),
          children: [
            // 新規作成ボタン
            CupertinoButton.filled(
              onPressed: () async {
                final newWorkflow = Workflow(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: '新しいワークフロー',
                  description: '',
                  promptTemplateId: '',
                  categories: [],
                );
                await workflowNotifier.addWorkflow(newWorkflow);
                if (context.mounted) {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => WorkflowEditScreen(
                        workflowId: newWorkflow.id,
                      ),
                    ),
                  );
                }
              },
              child: const Text('新規ワークフロー'),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // ワークフロー一覧
            if (workflows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'ワークフローがありません',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CupertinoColors.secondaryLabel),
                ),
              )
            else
              ...workflows.map((workflow) => _WorkflowCard(
                    workflow: workflow,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => WorkflowEditScreen(
                            workflowId: workflow.id,
                          ),
                        ),
                      );
                    },
                    onDelete: () async {
                      final confirmed = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('削除確認'),
                          content: Text('「${workflow.name}」を削除しますか？'),
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
                        await workflowNotifier.deleteWorkflow(workflow.id);
                      }
                    },
                  )),
          ],
        ),
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  final Workflow workflow;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WorkflowCard({
    required this.workflow,
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
        title: Text(workflow.name),
        subtitle: workflow.description.isNotEmpty
            ? Text(workflow.description)
            : null,
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

