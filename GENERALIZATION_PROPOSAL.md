# アプリ汎用化提案書

## 現状の課題

このアプリは汎用的なAI画像解析・データ処理ワークフロービルダーとして設計されています。

1. **カテゴリ管理**: カスタマイズ可能なカテゴリ定義
2. **プロンプトテンプレート**: カスタマイズ可能なプロンプトテンプレート
3. **固定データ構造**: 名簿、用地名などの特定のデータ構造
4. **固定出力フォーマット**: 特定のレポート形式

## 汎用化のアプローチ

### 1. ワークフロー/テンプレート管理システム

#### 提案内容
- 複数の「ワークフロー」を定義・保存できるようにする
- 各ワークフローには以下を含める：
  - プロンプトテンプレート
  - カテゴリ定義（カスタマイズ可能な分類）
  - データソース設定（名簿、API、ファイルなど）
  - 出力フォーマット定義
  - 除外/追加ルール設定

#### 実装イメージ
```dart
class Workflow {
  final String id;
  final String name;
  final String description;
  final PromptTemplate promptTemplate;
  final List<Category> categories;
  final DataSourceConfig dataSource;
  final OutputFormat outputFormat;
  final List<FilterRule> filterRules;
}
```

### 2. カテゴリ/分類の抽象化

#### 提案内容
- 「離島」「帰島」などの固定カテゴリを設定可能にする
- ユーザーが独自のカテゴリを定義できるようにする
- カテゴリごとに除外/追加ルールを設定可能に

#### 実装イメージ
```dart
class Category {
  final String id;
  final String name;
  final String description;
  final CategoryFilter filter; // このカテゴリに属する条件
  final List<String> excludedItems;
  final List<String> addedItems;
}
```

### 3. データソースの抽象化

#### 提案内容
- 名簿だけでなく、様々なデータソースに対応
  - ローカルファイル（CSV、JSON、Excel）
  - API（REST、GraphQL）
  - データベース
  - クラウドストレージ

#### 実装イメージ
```dart
abstract class DataSource {
  Future<List<DataItem>> fetch();
}

class LocalRosterDataSource extends DataSource { ... }
class ApiDataSource extends DataSource { ... }
class FileDataSource extends DataSource { ... }
```

### 4. 出力フォーマットのカスタマイズ

#### 提案内容
- 出力フォーマットをテンプレート化
- Markdown、JSON、CSV、カスタムテンプレートに対応
- プレースホルダーシステムで柔軟にカスタマイズ

#### 実装イメージ
```dart
class OutputFormat {
  final String template;
  final Map<String, String> placeholders;
  final OutputType type; // markdown, json, csv, custom
}
```

### 5. プロンプトテンプレート管理の強化

#### 提案内容
- 複数のプロンプトテンプレートを保存・管理
- テンプレートのバージョン管理
- テンプレートのインポート/エクスポート機能
- プレースホルダーの自動検出と置換

#### 実装イメージ
```dart
class PromptTemplate {
  final String id;
  final String name;
  final String content;
  final List<String> placeholders; // 自動検出
  final Map<String, String> defaultValues;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 6. 設定プロファイル機能

#### 提案内容
- 用途ごとの設定を「プロファイル」として保存
- プロファイルの切り替え機能
- プロファイルのインポート/エクスポート

#### 実装イメージ
```dart
class Profile {
  final String id;
  final String name;
  final Workflow workflow;
  final DataSourceConfig dataSource;
  final NotificationConfig notification;
  final Map<String, dynamic> customSettings;
}
```

### 7. プラグイン/拡張機能システム

#### 提案内容
- 新しい機能を追加できるプラグインシステム
- カスタムデータソース、出力フォーマット、通知方法などを追加可能に

#### 実装イメージ
```dart
abstract class Plugin {
  String get name;
  String get version;
  void initialize();
  void dispose();
}

abstract class DataSourcePlugin extends Plugin implements DataSource { ... }
abstract class OutputFormatPlugin extends Plugin implements OutputFormat { ... }
```

## 実装の優先順位

### Phase 1: 基本の汎用化（高優先度）
1. ✅ **プロンプトテンプレート管理の強化**
   - 複数テンプレートの保存・切り替え
   - プレースホルダーの自動検出

2. ✅ **カテゴリの抽象化**
   - 固定カテゴリ（離島/帰島）を設定可能に
   - カテゴリごとの除外/追加ルール

3. ✅ **出力フォーマットのカスタマイズ**
   - テンプレートベースの出力
   - 複数フォーマット対応

### Phase 2: データソースの拡張（中優先度）
4. **データソースの抽象化**
   - インターフェースの定義
   - 複数データソース対応

5. **設定プロファイル機能**
   - プロファイルの保存・読み込み
   - 切り替え機能

### Phase 3: 高度な機能（低優先度）
6. **ワークフロー管理システム**
   - 完全なワークフロー定義
   - ワークフローの保存・共有

7. **プラグインシステム**
   - プラグインアーキテクチャ
   - 拡張機能の追加

## 具体的な実装例

### 例1: カテゴリの抽象化

**現在:**
```dart
// ハードコードされたカテゴリ
final excludedIslanders = await settingsNotifier.getExcludedIslanders();
final excludedReturnees = await settingsNotifier.getExcludedReturnees();
```

**汎用化後:**
```dart
// 設定可能なカテゴリ
final categories = await settingsNotifier.getCategories();
for (final category in categories) {
  final excluded = await settingsNotifier.getExcludedItems(category.id);
  final added = await settingsNotifier.getAddedItems(category.id);
}
```

### 例2: プロンプトテンプレート管理

**現在:**
```dart
// 固定の2つのプロンプト
const String _defaultShipRoasterPrompt = "...";
const String _defaultBoardingPassPrompt = "...";
```

**汎用化後:**
```dart
// 複数のテンプレートを管理
class PromptTemplateManager {
  Future<List<PromptTemplate>> getAllTemplates();
  Future<PromptTemplate?> getTemplate(String id);
  Future<void> saveTemplate(PromptTemplate template);
  Future<void> deleteTemplate(String id);
}
```

### 例3: 出力フォーマットのカスタマイズ

**現在:**
```dart
// 固定の出力フォーマット
final output = """
【離島】
...
【帰島】
...
""";
```

**汎用化後:**
```dart
// テンプレートベースの出力
class OutputFormatter {
  String format(OutputTemplate template, Map<String, dynamic> data) {
    return template.render(data);
  }
}
```

## 移行戦略

### ステップ1: 後方互換性の維持
- 既存の機能を壊さないように、新しいシステムを段階的に導入
- デフォルトで既存の動作を維持

### ステップ2: 設定の移行
- 既存の設定を新しいシステムに自動移行
- 移行ツールの提供

### ステップ3: UIの段階的更新
- 既存のUIを維持しつつ、新しい機能を追加
- 設定画面で新機能を有効化

## 期待される効果

1. **再利用性の向上**: 様々な用途に応用可能
2. **保守性の向上**: 設定で変更可能になり、コード修正が不要
3. **拡張性の向上**: 新しい機能を追加しやすい
4. **ユーザビリティの向上**: ユーザーが自分でカスタマイズ可能

## 次のステップ

1. Phase 1の実装を開始
2. 既存機能の動作確認
3. 段階的に新機能を追加
4. ユーザーフィードバックの収集

