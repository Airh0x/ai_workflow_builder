import 'package:ai_workflow_builder/data_sources/data_source.dart';
import 'package:ai_workflow_builder/models/local_roster.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ローカル名簿データソース
/// 
/// 既存のLocalRosterモデルを使用したデータソース実装
class LocalRosterDataSource implements DataSource {
  @override
  final String id = 'local-roster';

  @override
  final String name = 'ローカル名簿';

  @override
  final String type = 'local';

  @override
  final String description = 'アプリ内に保存された名簿データ';

  static const String _rostersKey = 'savedRostersData';

  @override
  Future<List<DataItem>> fetch() async {
    final prefs = await SharedPreferences.getInstance();
    final rostersJson = prefs.getString(_rostersKey);
    
    if (rostersJson == null || rostersJson.isEmpty) {
      return [];
    }

    try {
      final rosters = LocalRoster.decode(rostersJson);
      return rosters.map((roster) {
        return DataItem(
          id: roster.id,
          data: {
            'name': roster.name,
            'content': roster.content,
          },
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> save(List<DataItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    
    final rosters = items.map((item) {
      return LocalRoster(
        id: item.id,
        name: item.data['name'] as String? ?? '',
        content: item.data['content'] as String? ?? '',
      );
    }).toList();

    final jsonString = LocalRoster.encode(rosters);
    await prefs.setString(_rostersKey, jsonString);
  }

  @override
  Map<String, dynamic> getConfig() {
    return {
      'type': type,
      'key': _rostersKey,
    };
  }

  @override
  Future<void> updateConfig(Map<String, dynamic> config) async {
    // ローカルデータソースは設定変更不要
  }
}

