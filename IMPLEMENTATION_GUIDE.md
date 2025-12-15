# 汎用化実装ガイド

## 概要

このガイドでは、「AI Workflow Builder」の実装手順を説明します。

## Phase 1: 基本の汎用化

### ステップ1: カテゴリの抽象化

#### 1-1. モデルの作成
✅ 完了: `lib/models/category.dart` を作成済み

#### 1-2. SettingsProviderの拡張

```dart
// lib/providers/settings_provider.dart に追加

// カテゴリ管理
Future<List<Category>> getCategories(String workflowId) async {
  // 実装
}

Future<void> saveCategories(String workflowId, List<Category> categories) async {
  // 実装
}

// カテゴリごとの除外/追加リスト
Future<List<String>> getExcludedItems(String categoryId) async {
  // 実装
}

Future<void> setExcludedItems(String categoryId, List<String> items) async {
  // 実装
}
```

#### 1-3. UIの更新

既存の固定カテゴリのUIを、動的なカテゴリリストに置き換え：

```dart
// lib/features/ship_roaster/widgets/category_section.dart (新規作成)

class CategorySection extends StatelessWidget {
  final Category category;
  final List<String> excludedItems;
  final List<String> addedItems;
  final Function(List<String>) onExcludedChanged;
  final Function(List<String>) onAddedChanged;
  
  // 実装
}
```

### ステップ2: プロンプトテンプレート管理の強化

#### 2-1. モデルの作成

```dart
// lib/models/prompt_template.dart (新規作成)

class PromptTemplate {
  final String id;
  final String name;
  final String description;
  final String content;
  final List<String> placeholders; // 自動検出
  final Map<String, String> defaultValues;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 実装
}
```

#### 2-2. プレースホルダーの自動検出

```dart
// lib/utils/prompt_processor.dart に追加

static List<String> detectPlaceholders(String template) {
  final regex = RegExp(r'\{(\w+)\}|%@');
  return regex.allMatches(template)
      .map((m) => m.group(1) ?? '%@')
      .toSet()
      .toList();
}
```

#### 2-3. UIの追加

プロンプトテンプレート管理画面を作成：

```dart
// lib/features/settings/prompt_templates_screen.dart (新規作成)

class PromptTemplatesScreen extends StatelessWidget {
  // テンプレート一覧
  // テンプレート作成・編集
  // テンプレート削除
  // テンプレートのインポート/エクスポート
}
```

### ステップ3: 出力フォーマットのカスタマイズ

#### 3-1. モデルの作成

```dart
// lib/models/output_format.dart (新規作成)

class OutputFormat {
  final String id;
  final String name;
  final String template;
  final OutputType type; // markdown, json, csv, custom
  final Map<String, String> placeholders;
  
  String render(Map<String, dynamic> data) {
    // テンプレートをレンダリング
  }
}

enum OutputType {
  markdown,
  json,
  csv,
  custom,
}
```

#### 3-2. フォーマッターの実装

```dart
// lib/utils/output_formatter.dart (新規作成)

class OutputFormatter {
  static String format(OutputFormat format, Map<String, dynamic> data) {
    switch (format.type) {
      case OutputType.markdown:
        return _formatMarkdown(format.template, data);
      case OutputType.json:
        return _formatJson(data);
      case OutputType.csv:
        return _formatCsv(data);
      case OutputType.custom:
        return _formatCustom(format.template, data);
    }
  }
}
```

## Phase 2: データソースの拡張

### ステップ4: データソースの抽象化

#### 4-1. インターフェースの定義

```dart
// lib/data_sources/data_source.dart (新規作成)

abstract class DataSource {
  String get id;
  String get name;
  String get type;
  
  Future<List<DataItem>> fetch();
  Future<void> save(List<DataItem> items);
}

class DataItem {
  final Map<String, dynamic> data;
  // 実装
}
```

#### 4-2. 実装クラス

```dart
// lib/data_sources/local_roster_data_source.dart
class LocalRosterDataSource extends DataSource { ... }

// lib/data_sources/api_data_source.dart
class ApiDataSource extends DataSource { ... }

// lib/data_sources/file_data_source.dart
class FileDataSource extends DataSource { ... }
```

## 移行手順

### ステップ1: 後方互換性の確保

1. 既存のコードを新しいシステムでラップ
2. デフォルトで既存の動作を維持
3. 段階的に新機能を有効化

### ステップ2: 設定の移行

1. 既存の設定を新しいモデルに変換
2. 移行スクリプトの作成
3. 移行の確認

### ステップ3: UIの更新

1. 既存のUIを維持
2. 新しい設定画面を追加
3. 段階的に機能を移行

## 実装の優先順位

### すぐに実装すべき（Phase 1）
1. ✅ カテゴリの抽象化モデル作成
2. ✅ ワークフローモデル作成
3. プロンプトテンプレート管理の強化
4. 出力フォーマットのカスタマイズ

### 次に実装すべき（Phase 2）
5. データソースの抽象化
6. 設定プロファイル機能

### 将来的に実装（Phase 3）
7. ワークフロー管理システム
8. プラグインシステム

## 注意事項

- 既存の機能を壊さないように注意
- 段階的に実装し、各段階でテスト
- ユーザーフィードバックを収集
- ドキュメントを更新

