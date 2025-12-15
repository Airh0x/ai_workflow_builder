/// カテゴリモデル
/// 
/// 汎用化のためのカテゴリ定義
/// 従来の「離島」「帰島」などの固定カテゴリを
/// 設定可能なカテゴリに置き換える
class Category {
  final String id;
  final String name;
  final String description;
  final CategoryFilter? filter;
  final List<String> excludedItems;
  final List<String> addedItems;
  final int order; // 表示順序

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.filter,
    List<String>? excludedItems,
    List<String>? addedItems,
    this.order = 0,
  })  : excludedItems = excludedItems ?? [],
        addedItems = addedItems ?? [];

  Category copyWith({
    String? id,
    String? name,
    String? description,
    CategoryFilter? filter,
    List<String>? excludedItems,
    List<String>? addedItems,
    int? order,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      filter: filter ?? this.filter,
      excludedItems: excludedItems ?? this.excludedItems,
      addedItems: addedItems ?? this.addedItems,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'filter': filter?.toJson(),
      'excludedItems': excludedItems,
      'addedItems': addedItems,
      'order': order,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      filter: json['filter'] != null
          ? CategoryFilter.fromJson(json['filter'] as Map<String, dynamic>)
          : null,
      excludedItems: (json['excludedItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      addedItems: (json['addedItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      order: json['order'] as int? ?? 0,
    );
  }
}

/// カテゴリフィルター
/// 
/// このカテゴリに属する条件を定義
class CategoryFilter {
  final String? field; // フィルタリングするフィールド名
  final String? value; // フィルタリングする値
  final FilterType type; // フィルタタイプ

  CategoryFilter({
    this.field,
    this.value,
    this.type = FilterType.equals,
  });

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'value': value,
      'type': type.name,
    };
  }

  factory CategoryFilter.fromJson(Map<String, dynamic> json) {
    return CategoryFilter(
      field: json['field'] as String?,
      value: json['value'] as String?,
      type: FilterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FilterType.equals,
      ),
    );
  }

  /// データアイテムがこのフィルターに一致するかチェック
  bool matches(Map<String, dynamic> item) {
    if (field == null || value == null) return true;

    final itemValue = item[field]?.toString();
    if (itemValue == null) return false;

    switch (type) {
      case FilterType.equals:
        return itemValue == value;
      case FilterType.contains:
        return itemValue.contains(value!);
      case FilterType.startsWith:
        return itemValue.startsWith(value!);
      case FilterType.endsWith:
        return itemValue.endsWith(value!);
      case FilterType.regex:
        return RegExp(value!).hasMatch(itemValue);
    }
  }
}

enum FilterType {
  equals,
  contains,
  startsWith,
  endsWith,
  regex,
}

