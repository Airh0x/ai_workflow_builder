import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/models/category.dart';
import 'package:ai_workflow_builder/models/workflow.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';
import 'package:ai_workflow_builder/features/workflow/category_edit_screen.dart';

/// カテゴリ管理画面
class CategoriesScreen extends ConsumerWidget {
  final String? workflowId;

  const CategoriesScreen({
    super.key,
    this.workflowId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflows = ref.watch(workflowProvider);
    final selectedWorkflowId = workflowId ?? (workflows.isNotEmpty ? workflows.first.id : null);
    final categoryNotifier = ref.read(categoryProvider.notifier);
    
    // 選択されたワークフローのカテゴリを読み込み
    if (selectedWorkflowId != null) {
      categoryNotifier.loadCategories(selectedWorkflowId);
    }
    
    final categoriesMap = ref.watch(categoryProvider);
    final categories = selectedWorkflowId != null
        ? (categoriesMap[selectedWorkflowId] ?? <Category>[])
        : <Category>[];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('カテゴリ管理'),
        trailing: workflows.isNotEmpty && selectedWorkflowId != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  _showWorkflowSelector(context, ref, workflows, selectedWorkflowId!);
                },
                child: const Text('ワークフロー選択'),
              )
            : null,
      ),
      child: SafeArea(
        child: selectedWorkflowId == null
            ? const Center(
                child: Text(
                  'ワークフローがありません',
                  style: TextStyle(color: CupertinoColors.secondaryLabel),
                ),
              )
            : ListView(
                padding: EdgeInsets.all(AppTheme.paddingStandard),
                children: [
                  // ワークフロー情報
                  if (workflows.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(AppTheme.paddingStandard),
                      margin: EdgeInsets.only(bottom: AppTheme.paddingStandard),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusStandard),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.list_bullet),
                          SizedBox(width: AppTheme.paddingStandard / 2),
                          Expanded(
                            child: Text(
                              'ワークフロー: ${workflows.firstWhere((w) => w.id == selectedWorkflowId).name}',
                              style: AppTheme.body(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // 新規作成ボタン
                  CupertinoButton.filled(
                    onPressed: selectedWorkflowId == null
                        ? null
                        : () async {
                            final workflowId = selectedWorkflowId;
                            final newCategory = Category(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: '新しいカテゴリ',
                              description: '',
                              order: categories.length,
                            );
                            final updatedCategories = [...categories, newCategory];
                            await categoryNotifier.saveCategories(
                              workflowId,
                              updatedCategories,
                            );
                            if (context.mounted) {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => CategoryEditScreen(
                                    workflowId: workflowId,
                                    categoryId: newCategory.id,
                                  ),
                                ),
                              );
                            }
                          },
                    child: const Text('新規カテゴリ'),
                  ),
                  SizedBox(height: AppTheme.paddingStandard),
                  // カテゴリ一覧
                  if (categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'カテゴリがありません',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: CupertinoColors.secondaryLabel),
                      ),
                    )
                  else
                    ...categories.map((category) {
                      final workflowId = selectedWorkflowId;
                      return _CategoryCard(
                        category: category,
                        workflowId: workflowId,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => CategoryEditScreen(
                                workflowId: workflowId,
                                categoryId: category.id,
                              ),
                            ),
                          );
                        },
                        onDelete: () async {
                          final confirmed = await showCupertinoDialog<bool>(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('削除確認'),
                              content: Text('「${category.name}」を削除しますか？'),
                              actions: [
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('削除'),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('キャンセル'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            final updatedCategories = categories
                                .where((c) => c.id != category.id)
                                .toList();
                            await categoryNotifier.saveCategories(
                              workflowId,
                              updatedCategories,
                            );
                          }
                        },
                      );
                    }),
                ],
              ),
      ),
    );
  }

  void _showWorkflowSelector(
    BuildContext context,
    WidgetRef ref,
    List<Workflow> workflows,
    String currentWorkflowId,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('ワークフローを選択'),
        actions: workflows.map((workflow) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (context) => CategoriesScreen(
                    workflowId: workflow.id,
                  ),
                ),
              );
            },
            child: Text(
              workflow.name,
              style: TextStyle(
                fontWeight: workflow.id == currentWorkflowId
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final String workflowId;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.workflowId,
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
        title: Text(category.name),
        subtitle: category.description.isNotEmpty
            ? Text(category.description)
            : Text(
                '除外: ${category.excludedItems.length}件, 追加: ${category.addedItems.length}件',
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

