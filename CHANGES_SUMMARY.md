# 汎用化変更サマリー

## プロジェクト情報

- **プロジェクト名**: `ai_workflow_builder`
- **場所**: `/Users/februarysnow/Desktop/ai_workflow_builder`
- **元プロジェクト**: `shipflow_ai` (汎用化により `ai_workflow_builder` に変更)

## 実装した汎用化機能

### 1. 新しいモデルクラス

#### `lib/models/workflow.dart`
- ワークフロー定義モデル
- プロンプトテンプレート、カテゴリ、データソース、出力フォーマットを統合管理
- デフォルトのワークフロー作成メソッド付き

#### `lib/models/category.dart`
- カテゴリ定義モデル（汎用的なカテゴリ管理）
- カテゴリフィルター機能
- 除外/追加アイテム管理

#### `lib/models/prompt_template.dart`
- プロンプトテンプレートモデル
- プレースホルダーの自動検出
- プレースホルダー置換機能
- JSONエンコード/デコード

#### `lib/models/output_format.dart`
- 出力フォーマットモデル
- Markdown、JSON、CSV、カスタムテンプレート対応
- データレンダリング機能

### 2. 新しいプロバイダー

#### `lib/providers/workflow_provider.dart`
- `WorkflowNotifier`: ワークフロー管理
- `PromptTemplateNotifier`: プロンプトテンプレート管理
- `OutputFormatNotifier`: 出力フォーマット管理
- `CategoryNotifier`: カテゴリ管理（ワークフローごと）

### 3. データソース抽象化

#### `lib/data_sources/data_source.dart`
- データソース抽象インターフェース
- `DataItem`モデル

#### `lib/data_sources/local_roster_data_source.dart`
- ローカル名簿データソースの実装
- 既存の`LocalRoster`モデルを使用

### 4. ワークフロープロセッサー

#### `lib/utils/workflow_processor.dart`
- ワークフローに基づいたプロンプト処理
- カテゴリごとの除外/追加ルールの適用
- 出力フォーマット処理

### 5. ワークフロービューモデル

#### `lib/features/workflow/view_models/workflow_view_model.dart`
- 汎用化されたワークフロー実行管理
- 画像選択、ワークフロー実行、LINE送信機能

## 後方互換性

既存のコードは引き続き動作します：

- ✅ `SettingsNotifier`: 既存のメソッドは維持
- ✅ `PromptProcessor`: 既存のメソッドは維持
- ✅ `ShipRoasterViewModel`: 既存の機能は維持
- ✅ 既存のUI: 引き続き動作

## 主な改善点

### 1. カテゴリの抽象化
- **従来**: 固定カテゴリがハードコード
- **汎用化**: 任意のカテゴリを定義可能

### 2. プロンプトテンプレート管理
- **従来**: 2つの固定プロンプト
- **汎用化**: 無制限のテンプレートを保存・管理

### 3. 出力フォーマット
- **従来**: 固定のMarkdown形式
- **汎用化**: Markdown、JSON、CSV、カスタムテンプレート

### 4. データソース
- **従来**: ローカル名簿のみ
- **汎用化**: 複数のデータソースに対応（拡張可能）

## 使用方法

### ワークフローの作成

```dart
final workflowNotifier = ref.read(workflowProvider.notifier);
final workflow = Workflow.createDefaultWorkflow();
await workflowNotifier.addWorkflow(workflow);
```

### プロンプトテンプレートの使用

```dart
final templateNotifier = ref.read(promptTemplateProvider.notifier);
final template = PromptTemplate(
  id: 'my-template',
  name: 'マイテンプレート',
  description: '説明',
  content: 'プロンプト内容...',
);
await templateNotifier.addTemplate(template);
```

### ワークフローの実行

```dart
final workflowViewModel = ref.read(workflowViewModelProvider.notifier);
await workflowViewModel.executeWorkflow(
  masterRoster: masterRoster,
  sheetName: sheetName,
);
```

## 次のステップ

1. **UIの更新**: ワークフロー管理、プロンプトテンプレート管理、カテゴリ管理のUIを実装
2. **既存UIの移行**: 段階的に既存のUIを新システムに移行
3. **データ移行**: 既存の設定データを新しいシステムに移行
4. **テスト**: 既存機能の動作確認と新機能のテスト

## ファイル構成

```
lib/
├── models/
│   ├── workflow.dart          # 新規: ワークフローモデル
│   ├── category.dart          # 新規: カテゴリモデル
│   ├── prompt_template.dart   # 新規: プロンプトテンプレート
│   ├── output_format.dart     # 新規: 出力フォーマット
│   └── local_roster.dart      # 既存: ローカル名簿
├── providers/
│   ├── workflow_provider.dart # 新規: ワークフロー管理
│   └── settings_provider.dart # 既存: 設定管理（後方互換性維持）
├── data_sources/
│   ├── data_source.dart       # 新規: データソース抽象化
│   └── local_roster_data_source.dart # 新規: ローカル名簿実装
├── features/
│   └── workflow/
│       └── view_models/
│           └── workflow_view_model.dart # 新規: ワークフロービューモデル
└── utils/
    └── workflow_processor.dart # 新規: ワークフロープロセッサー
```

## 注意事項

- 既存の機能は後方互換性のために維持されています
- 段階的に新機能を追加しています
- 完全な移行は今後実装予定です

