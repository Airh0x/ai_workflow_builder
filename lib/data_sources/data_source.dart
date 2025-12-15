/// データソース抽象インターフェース
/// 
/// 汎用化のためのデータソース定義
/// 様々なデータソース（ローカルファイル、API、データベースなど）に対応
abstract class DataSource {
  String get id;
  String get name;
  String get type;
  String get description;

  /// データを取得
  Future<List<DataItem>> fetch();

  /// データを保存
  Future<void> save(List<DataItem> items);

  /// データソースの設定を取得
  Map<String, dynamic> getConfig();

  /// データソースの設定を更新
  Future<void> updateConfig(Map<String, dynamic> config);
}

/// データアイテム
class DataItem {
  final Map<String, dynamic> data;
  final String? id;

  DataItem({
    required this.data,
    this.id,
  });

  DataItem copyWith({
    Map<String, dynamic>? data,
    String? id,
  }) {
    return DataItem(
      data: data ?? this.data,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
    };
  }

  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      id: json['id'] as String?,
      data: json['data'] as Map<String, dynamic>,
    );
  }
}

