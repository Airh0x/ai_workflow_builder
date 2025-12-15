import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/models/workflow.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';

/// ワークフロー編集画面
class WorkflowEditScreen extends ConsumerStatefulWidget {
  final String workflowId;

  const WorkflowEditScreen({
    super.key,
    required this.workflowId,
  });

  @override
  ConsumerState<WorkflowEditScreen> createState() =>
      _WorkflowEditScreenState();
}

class _WorkflowEditScreenState extends ConsumerState<WorkflowEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  Workflow? _workflow;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadWorkflow();
  }

  void _loadWorkflow() {
    final workflowNotifier = ref.read(workflowProvider.notifier);
    _workflow = workflowNotifier.getWorkflow(widget.workflowId);
    if (_workflow != null) {
      _nameController.text = _workflow!.name;
      _descriptionController.text = _workflow!.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkflow() async {
    if (_workflow == null) return;

    final workflowNotifier = ref.read(workflowProvider.notifier);
    final updatedWorkflow = _workflow!.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
    );
    await workflowNotifier.updateWorkflow(updatedWorkflow);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_workflow == null) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('ワークフロー編集'),
        ),
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('ワークフロー編集'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveWorkflow,
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppTheme.paddingStandard),
          children: [
            // 名前
            CupertinoTextField(
              controller: _nameController,
              placeholder: 'ワークフロー名',
              padding: EdgeInsets.all(AppTheme.paddingStandard),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // 説明
            CupertinoTextField(
              controller: _descriptionController,
              placeholder: '説明',
              maxLines: 3,
              padding: EdgeInsets.all(AppTheme.paddingStandard),
            ),
            SizedBox(height: AppTheme.paddingStandard * 2),
            // カテゴリ情報
            Text(
              'カテゴリ: ${_workflow!.categories.length}個',
              style: AppTheme.body(context),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // プロンプトテンプレート情報
            Text(
              'プロンプトテンプレート: ${_workflow!.promptTemplateId}',
              style: AppTheme.body(context),
            ),
          ],
        ),
      ),
    );
  }
}

