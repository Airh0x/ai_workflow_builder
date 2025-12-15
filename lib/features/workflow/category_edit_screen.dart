import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/models/category.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';

/// カテゴリ編集画面
class CategoryEditScreen extends ConsumerStatefulWidget {
  final String workflowId;
  final String categoryId;

  const CategoryEditScreen({
    super.key,
    required this.workflowId,
    required this.categoryId,
  });

  @override
  ConsumerState<CategoryEditScreen> createState() =>
      _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _filterFieldController;
  late final TextEditingController _filterValueController;
  Category? _category;
  FilterType _selectedFilterType = FilterType.equals;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _filterFieldController = TextEditingController();
    _filterValueController = TextEditingController();
    _loadCategory();
  }

  void _loadCategory() {
    final categoriesMap = ref.read(categoryProvider);
    final categories = categoriesMap[widget.workflowId] ?? [];
    _category = categories.firstWhere(
      (c) => c.id == widget.categoryId,
      orElse: () => Category(
        id: widget.categoryId,
        name: '新しいカテゴリ',
        description: '',
        order: categories.length,
      ),
    );
    _nameController.text = _category!.name;
    _descriptionController.text = _category!.description;
    _selectedFilterType = _category!.filter?.type ?? FilterType.equals;
    _filterFieldController.text = _category!.filter?.field ?? '';
    _filterValueController.text = _category!.filter?.value ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _filterFieldController.dispose();
    _filterValueController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_category == null) return;

    final categoryNotifier = ref.read(categoryProvider.notifier);
    final categoriesMap = ref.read(categoryProvider);
    final categories = categoriesMap[widget.workflowId] ?? [];

    final filterField = _filterFieldController.text.trim();
    final filterValue = _filterValueController.text.trim();
    final updatedCategory = _category!.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
      filter: (filterField.isNotEmpty && filterValue.isNotEmpty)
          ? CategoryFilter(
              field: filterField,
              value: filterValue,
              type: _selectedFilterType,
            )
          : null,
    );

    final updatedCategories = categories
        .map((c) => c.id == widget.categoryId ? updatedCategory : c)
        .toList();

    // 新規カテゴリの場合は追加
    if (!categories.any((c) => c.id == widget.categoryId)) {
      updatedCategories.add(updatedCategory);
    }

    await categoryNotifier.saveCategories(widget.workflowId, updatedCategories);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_category == null) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('カテゴリ編集'),
        ),
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('カテゴリ編集'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveCategory,
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
              placeholder: 'カテゴリ名',
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
            // フィルター設定
            Text(
              'フィルター設定（オプション）',
              style: AppTheme.subheadline(context),
            ),
            SizedBox(height: AppTheme.paddingStandard / 2),
            // フィルタータイプ
            CupertinoSegmentedControl<FilterType>(
              groupValue: _selectedFilterType,
              children: const {
                FilterType.equals: Text('完全一致'),
                FilterType.contains: Text('部分一致'),
                FilterType.startsWith: Text('前方一致'),
                FilterType.endsWith: Text('後方一致'),
                FilterType.regex: Text('正規表現'),
              },
              onValueChanged: (value) {
                setState(() {
                  _selectedFilterType = value;
                });
              },
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // フィルターフィールド
            CupertinoTextField(
              placeholder: 'フィルターフィールド名',
              controller: _filterFieldController,
              padding: EdgeInsets.all(AppTheme.paddingStandard),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // フィルター値
            CupertinoTextField(
              placeholder: 'フィルター値',
              controller: _filterValueController,
              padding: EdgeInsets.all(AppTheme.paddingStandard),
            ),
            SizedBox(height: AppTheme.paddingStandard),
            // 除外/追加アイテム情報
            Container(
              padding: EdgeInsets.all(AppTheme.paddingStandard),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusStandard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '除外アイテム: ${_category!.excludedItems.length}件',
                    style: AppTheme.body(context),
                  ),
                  SizedBox(height: AppTheme.paddingStandard / 2),
                  Text(
                    '追加アイテム: ${_category!.addedItems.length}件',
                    style: AppTheme.body(context),
                  ),
                  SizedBox(height: AppTheme.paddingStandard / 2),
                  Text(
                    '※ 除外/追加アイテムの編集は、ワークフロー実行画面から行います',
                    style: AppTheme.caption1(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

