import 'package:ai_workflow_builder/models/category.dart';

/// ワークフローモデル
///
/// 汎用化のためのワークフロー定義
/// プロンプト、カテゴリ、データソース、出力フォーマットなどを
/// まとめて管理する
class Workflow {
  final String id;
  final String name;
  final String description;
  final String promptTemplateId;
  final List<Category> categories;
  final String? dataSourceId;
  final String? outputFormatId;
  final Map<String, dynamic> customSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workflow({
    required this.id,
    required this.name,
    required this.description,
    required this.promptTemplateId,
    List<Category>? categories,
    this.dataSourceId,
    this.outputFormatId,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : categories = categories ?? [],
       customSettings = customSettings ?? {},
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Workflow copyWith({
    String? id,
    String? name,
    String? description,
    String? promptTemplateId,
    List<Category>? categories,
    String? dataSourceId,
    String? outputFormatId,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workflow(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      promptTemplateId: promptTemplateId ?? this.promptTemplateId,
      categories: categories ?? this.categories,
      dataSourceId: dataSourceId ?? this.dataSourceId,
      outputFormatId: outputFormatId ?? this.outputFormatId,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'promptTemplateId': promptTemplateId,
      'categories': categories.map((c) => c.toJson()).toList(),
      'dataSourceId': dataSourceId,
      'outputFormatId': outputFormatId,
      'customSettings': customSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      promptTemplateId: json['promptTemplateId'] as String,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dataSourceId: json['dataSourceId'] as String?,
      outputFormatId: json['outputFormatId'] as String?,
      customSettings: json['customSettings'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// デフォルトのワークフローを作成
  static Workflow createDefaultWorkflow() {
    return Workflow(
      id: 'default-workflow',
      name: 'デフォルトワークフロー',
      description: '基本的なデータ処理ワークフロー',
      promptTemplateId: 'default-prompt',
      categories: [
        Category(
          id: 'category-a',
          name: 'カテゴリA',
          description: 'カテゴリAに分類されるアイテム',
          filter: CategoryFilter(
            field: 'status',
            value: 'active',
            type: FilterType.equals,
          ),
          order: 1,
        ),
        Category(
          id: 'category-b',
          name: 'カテゴリB',
          description: 'カテゴリBに分類されるアイテム',
          filter: CategoryFilter(
            field: 'status',
            value: 'inactive',
            type: FilterType.equals,
          ),
          order: 2,
        ),
      ],
    );
  }
}
