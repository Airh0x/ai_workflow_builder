# 汎用化移行ガイド

## 概要

このドキュメントは、汎用化された「AI Workflow Builder」の使用方法を説明します。

## 主な変更点

### 1. パッケージ名の変更

### 1. パッケージ名

- **パッケージ名**: `package:ai_workflow_builder`

### 2. アプリ名

- **アプリ名**: "AI Workflow Builder"

### 3. モデルクラス

以下のモデルクラスが利用可能です：

- `Workflow`: ワークフロー定義
- `Category`: カテゴリ定義（汎用的なカテゴリ管理）
- `PromptTemplate`: プロンプトテンプレート
- `OutputFormat`: 出力フォーマット
- `DataSource`: データソース抽象化

### 4. 新しいプロバイダー

- `WorkflowNotifier`: ワークフロー管理
- `PromptTemplateNotifier`: プロンプトテンプレート管理
- `OutputFormatNotifier`: 出力フォーマット管理
- `CategoryNotifier`: カテゴリ管理

### 5. 後方互換性

既存の`SettingsNotifier`は後方互換性のために残されており、既存のコードは引き続き動作します。

## 移行手順

### ステップ1: 既存機能の確認

既存の機能（データ処理、画像読み取り）は引き続き動作します。

### ステップ2: 新しい機能の使用

新しい汎用化機能を使用するには：

1. **ワークフローの作成**
   ```dart
   final workflowNotifier = ref.read(workflowProvider.notifier);
   final workflow = Workflow.createDefaultWorkflow();
   await workflowNotifier.addWorkflow(workflow);
   ```

2. **プロンプトテンプレートの使用**
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

3. **ワークフロープロセッサーの使用**
   ```dart
   final prompt = await WorkflowProcessor.processWorkflowPrompt(
     ref,
     workflow,
     data: {
       'MASTER_ROSTER': masterRoster,
       'SHEET_NAME': sheetName,
     },
   );
   ```

## 既存コードとの互換性

### 既存のSettingsNotifier

既存の`SettingsNotifier`のメソッドは引き続き使用可能です：

- `getExcludedIslanders()` → 新しい`CategoryNotifier`に移行可能
- `getExcludedReturnees()` → 新しい`CategoryNotifier`に移行可能
- `getAddedIslanders()` → 新しい`CategoryNotifier`に移行可能
- `getAddedReturnees()` → 新しい`CategoryNotifier`に移行可能

### 既存のPromptProcessor

既存の`PromptProcessor.processPrompt()`は引き続き動作しますが、新しい`WorkflowProcessor`の使用を推奨します。

## 段階的な移行

### Phase 1: 既存機能の維持（完了）

- ✅ 既存のコードが動作することを確認
- ✅ 後方互換性の確保

### Phase 2: 新機能の追加（進行中）

- ✅ ワークフロー管理の実装
- ✅ プロンプトテンプレート管理の実装
- ✅ カテゴリ管理の実装
- ⏳ UIの更新（今後実装）

### Phase 3: 完全な移行（今後）

- ⏳ 既存UIの新システムへの移行
- ⏳ データの移行
- ⏳ 完全な汎用化

## 注意事項

1. **既存の設定データ**: 既存の設定データは引き続き使用可能です
2. **段階的な移行**: 既存の機能を壊さずに、段階的に新機能を追加しています
3. **テスト**: 既存の機能が正常に動作することを確認してください

## 次のステップ

1. 新しいワークフロー管理UIの実装
2. プロンプトテンプレート管理UIの実装
3. カテゴリ管理UIの実装
4. 既存UIの段階的な移行

