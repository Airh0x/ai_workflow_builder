import 'dart:convert';

/// プロンプトテンプレートモデル
/// 
/// 汎用化のためのプロンプトテンプレート定義
class PromptTemplate {
  final String id;
  final String name;
  final String description;
  final String content;
  final List<String> placeholders; // 自動検出されたプレースホルダー
  final Map<String, String> defaultValues;
  final DateTime createdAt;
  final DateTime updatedAt;

  PromptTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.content,
    List<String>? placeholders,
    Map<String, String>? defaultValues,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : placeholders = placeholders ?? _detectPlaceholders(content),
        defaultValues = defaultValues ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  PromptTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? content,
    List<String>? placeholders,
    Map<String, String>? defaultValues,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final newContent = content ?? this.content;
    return PromptTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      content: newContent,
      placeholders: placeholders ?? _detectPlaceholders(newContent),
      defaultValues: defaultValues ?? this.defaultValues,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// プレースホルダーを自動検出
  static List<String> _detectPlaceholders(String template) {
    final placeholders = <String>[];
    
    // {PLACEHOLDER}形式を検出
    final bracePattern = RegExp(r'\{(\w+)\}');
    for (final match in bracePattern.allMatches(template)) {
      final placeholder = match.group(1);
      if (placeholder != null && !placeholders.contains(placeholder)) {
        placeholders.add(placeholder);
      }
    }
    
    // %@形式を検出
    if (template.contains('%@')) {
      if (!placeholders.contains('%@')) {
        placeholders.add('%@');
      }
    }
    
    return placeholders;
  }

  /// プレースホルダーを置換
  String replacePlaceholders(Map<String, String> values) {
    var result = content;
    
    // {PLACEHOLDER}形式を置換
    for (final placeholder in placeholders) {
      if (placeholder == '%@') continue; // %@は別途処理
      
      final value = values[placeholder] ?? defaultValues[placeholder] ?? '';
      result = result.replaceAll('{$placeholder}', value);
    }
    
    // %@形式を置換（最初の1つだけ）
    if (values.containsKey('%@')) {
      result = result.replaceFirst('%@', values['%@']!);
    }
    
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'content': content,
      'placeholders': placeholders,
      'defaultValues': defaultValues,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PromptTemplate.fromJson(Map<String, dynamic> json) {
    return PromptTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      content: json['content'] as String,
      placeholders: (json['placeholders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      defaultValues: (json['defaultValues'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())) ??
          {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static String encode(List<PromptTemplate> templates) {
    return json.encode(
      templates.map((t) => t.toJson()).toList(),
    );
  }

  static List<PromptTemplate> decode(String jsonString) {
    if (jsonString.isEmpty) return [];
    final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => PromptTemplate.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

