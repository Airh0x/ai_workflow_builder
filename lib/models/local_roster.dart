import 'dart:convert';

import 'package:uuid/uuid.dart';

class LocalRoster {
  final String id;
  final String name;
  final String content;

  LocalRoster({String? id, required this.name, required this.content})
    : id = id ?? const Uuid().v4();

  // JSONからLocalRosterオブジェクトを生成するファクトリコンストラクタ
  factory LocalRoster.fromJson(Map<String, dynamic> json) {
    return LocalRoster(
      id: json['id'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
    );
  }

  // LocalRosterオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'content': content};
  }

  // LocalRosterオブジェクトのリストをJSON文字列にエンコードする静的メソッド
  static String encode(List<LocalRoster> rosters) => json.encode(
    rosters.map<Map<String, dynamic>>((roster) => roster.toJson()).toList(),
  );

  // JSON文字列をデコードしてLocalRosterオブジェクトのリストを生成する静的メソッド
  static List<LocalRoster> decode(String rosters) =>
      (json.decode(rosters) as List<dynamic>)
          .map<LocalRoster>((item) => LocalRoster.fromJson(item))
          .toList();
}
