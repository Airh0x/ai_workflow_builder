import 'dart:convert';

/// 出力フォーマットモデル
///
/// 汎用化のための出力フォーマット定義
class OutputFormat {
  final String id;
  final String name;
  final String description;
  final String template;
  final OutputType type;
  final Map<String, String> placeholders;

  OutputFormat({
    required this.id,
    required this.name,
    required this.description,
    required this.template,
    required this.type,
    Map<String, String>? placeholders,
  }) : placeholders = placeholders ?? {};

  OutputFormat copyWith({
    String? id,
    String? name,
    String? description,
    String? template,
    OutputType? type,
    Map<String, String>? placeholders,
  }) {
    return OutputFormat(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      template: template ?? this.template,
      type: type ?? this.type,
      placeholders: placeholders ?? this.placeholders,
    );
  }

  /// データをレンダリング
  String render(Map<String, dynamic> data) {
    switch (type) {
      case OutputType.markdown:
        return _renderMarkdown(data);
      case OutputType.json:
        return _renderJson(data);
      case OutputType.csv:
        return _renderCsv(data);
      case OutputType.custom:
        return _renderCustom(data);
    }
  }

  String _renderMarkdown(Map<String, dynamic> data) {
    var result = template;
    for (final entry in data.entries) {
      final key = entry.key;
      final value = _formatValue(entry.value);
      result = result.replaceAll('{$key}', value);
    }
    return result;
  }

  String _renderJson(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String _renderCsv(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // ヘッダー
    buffer.writeln(data.keys.join(','));

    // データ行
    final values = data.values.map((v) => _formatCsvValue(v)).toList();
    buffer.writeln(values.join(','));

    return buffer.toString();
  }

  String _renderCustom(Map<String, dynamic> data) {
    var result = template;
    for (final entry in data.entries) {
      final key = entry.key;
      final value = _formatValue(entry.value);
      result = result.replaceAll('{$key}', value);
    }
    return result;
  }

  String _formatValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.map((e) => e.toString()).join(', ');
    }
    return value.toString();
  }

  String _formatCsvValue(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    // CSVの特殊文字をエスケープ
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'template': template,
      'type': type.name,
      'placeholders': placeholders,
    };
  }

  factory OutputFormat.fromJson(Map<String, dynamic> json) {
    return OutputFormat(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      template: json['template'] as String,
      type: OutputType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OutputType.markdown,
      ),
      placeholders:
          (json['placeholders'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          {},
    );
  }

  static String encode(List<OutputFormat> formats) {
    return json.encode(formats.map((f) => f.toJson()).toList());
  }

  static List<OutputFormat> decode(String jsonString) {
    if (jsonString.isEmpty) return [];
    final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => OutputFormat.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

enum OutputType { markdown, json, csv, custom }
