import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/models/prompt_template.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';

/// プロンプトテンプレート編集画面
class PromptTemplateEditScreen extends ConsumerStatefulWidget {
  final String templateId;

  const PromptTemplateEditScreen({
    super.key,
    required this.templateId,
  });

  @override
  ConsumerState<PromptTemplateEditScreen> createState() =>
      _PromptTemplateEditScreenState();
}

class _PromptTemplateEditScreenState
    extends ConsumerState<PromptTemplateEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contentController;
  PromptTemplate? _template;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _contentController = TextEditingController();
    _loadTemplate();
  }

  void _loadTemplate() {
    final templates = ref.read(promptTemplateProvider);
    _template = templates.firstWhere(
      (t) => t.id == widget.templateId,
      orElse: () => PromptTemplate(
        id: widget.templateId,
        name: '新しいテンプレート',
        description: '',
        content: '',
      ),
    );
    _nameController.text = _template!.name;
    _descriptionController.text = _template!.description;
    _contentController.text = _template!.content;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (_template == null) return;

    final templateNotifier = ref.read(promptTemplateProvider.notifier);
    final updatedTemplate = _template!.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      content: _contentController.text,
    );

    final existingTemplate = templateNotifier.getTemplate(widget.templateId);
    if (existingTemplate != null) {
      await templateNotifier.updateTemplate(updatedTemplate);
    } else {
      await templateNotifier.addTemplate(updatedTemplate);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_template == null) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('テンプレート編集'),
        ),
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    final placeholders = _template!.placeholders;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('テンプレート編集'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveTemplate,
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
              placeholder: 'テンプレート名',
              padding: EdgeInsets.all(AppTheme.paddingStandard),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // 説明
            CupertinoTextField(
              controller: _descriptionController,
              placeholder: '説明',
              maxLines: 2,
              padding: EdgeInsets.all(AppTheme.paddingStandard),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // プレースホルダー情報
            if (placeholders.isNotEmpty) ...[
              Text(
                '検出されたプレースホルダー:',
                style: AppTheme.subheadline(context),
              ),
              SizedBox(height: AppTheme.paddingStandard / 2),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: placeholders.map((placeholder) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingStandard / 2,
                      vertical: AppTheme.paddingCompact,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusStandard / 2,
                      ),
                    ),
                    child: Text(
                      placeholder,
                      style: AppTheme.caption1(context),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: AppTheme.paddingStandard),
            ],
            // コンテンツ
            Text(
              'プロンプト内容:',
              style: AppTheme.subheadline(context),
            ),
            SizedBox(height: AppTheme.paddingStandard / 2),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusStandard),
              ),
              child: CupertinoTextField(
                controller: _contentController,
                placeholder: 'プロンプトテンプレートを入力...',
                maxLines: null,
                expands: true,
                padding: EdgeInsets.all(AppTheme.paddingStandard),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

