import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/models/output_format.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';

/// 出力フォーマット編集画面
class OutputFormatEditScreen extends ConsumerStatefulWidget {
  final String formatId;

  const OutputFormatEditScreen({
    super.key,
    required this.formatId,
  });

  @override
  ConsumerState<OutputFormatEditScreen> createState() =>
      _OutputFormatEditScreenState();
}

class _OutputFormatEditScreenState
    extends ConsumerState<OutputFormatEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _templateController;
  OutputFormat? _format;
  OutputType _selectedType = OutputType.markdown;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _templateController = TextEditingController();
    _loadFormat();
  }

  void _loadFormat() {
    final formats = ref.read(outputFormatProvider);
    _format = formats.firstWhere(
      (f) => f.id == widget.formatId,
      orElse: () => OutputFormat(
        id: widget.formatId,
        name: '新しいフォーマット',
        description: '',
        template: '',
        type: OutputType.markdown,
      ),
    );
    _nameController.text = _format!.name;
    _descriptionController.text = _format!.description;
    _templateController.text = _format!.template;
    _selectedType = _format!.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _templateController.dispose();
    super.dispose();
  }

  Future<void> _saveFormat() async {
    if (_format == null) return;

    final formatNotifier = ref.read(outputFormatProvider.notifier);
    final updatedFormat = _format!.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      template: _templateController.text,
      type: _selectedType,
    );

    final existingFormat = formatNotifier.getFormat(widget.formatId);
    if (existingFormat != null) {
      await formatNotifier.updateFormat(updatedFormat);
    } else {
      await formatNotifier.addFormat(updatedFormat);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

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

  String _getTypeDescription(OutputType type) {
    switch (type) {
      case OutputType.markdown:
        return 'Markdown形式で出力します。プレースホルダー {key} を使用できます。';
      case OutputType.json:
        return 'JSON形式で出力します。テンプレートは使用されません。';
      case OutputType.csv:
        return 'CSV形式で出力します。テンプレートは使用されません。';
      case OutputType.custom:
        return 'カスタムテンプレートを使用します。プレースホルダー {key} を使用できます。';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_format == null) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('フォーマット編集'),
        ),
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    final isTemplateBased = _selectedType == OutputType.markdown ||
        _selectedType == OutputType.custom;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('フォーマット編集'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveFormat,
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
              placeholder: 'フォーマット名',
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
            // タイプ選択
            Text(
              '出力タイプ',
              style: AppTheme.subheadline(context),
            ),
            SizedBox(height: AppTheme.paddingStandard / 2),
            CupertinoSegmentedControl<OutputType>(
              groupValue: _selectedType,
              children: {
                OutputType.markdown: const Text('Markdown'),
                OutputType.json: const Text('JSON'),
                OutputType.csv: const Text('CSV'),
                OutputType.custom: const Text('カスタム'),
              },
              onValueChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // タイプ説明
            Container(
              padding: EdgeInsets.all(AppTheme.paddingStandard),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusStandard),
              ),
              child: Text(
                _getTypeDescription(_selectedType),
                style: AppTheme.caption1(context),
              ),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // テンプレート（Markdown/Custom の場合のみ）
            if (isTemplateBased) ...[
              Text(
                'テンプレート:',
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
                  controller: _templateController,
                  placeholder: 'テンプレートを入力...\n例: # {title}\n\n{content}',
                  maxLines: null,
                  expands: true,
                  padding: EdgeInsets.all(AppTheme.paddingStandard),
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              SizedBox(height: AppTheme.paddingStandard / 2),
              Text(
                'プレースホルダー: {key} の形式で使用できます',
                style: AppTheme.caption1(context),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(AppTheme.paddingStandard),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusStandard),
                ),
                child: Text(
                  '${_getTypeLabel(_selectedType)}形式では、テンプレートは使用されません。データが自動的にフォーマットされます。',
                  style: AppTheme.body(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

