# AI Workflow Builder

汎用AI画像解析・データ処理ワークフロービルダー

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📖 概要

AI Workflow Builderは、Google Gemini APIを使用した画像解析とデータ処理を、カスタマイズ可能なワークフローで実行できる汎用的なFlutterアプリケーションです。

### 開発の背景

このプロジェクトは、AIを活用した画像解析とデータ処理のワークフローを構築するための汎用的なフレームワークとして開発されました。カスタマイズ可能なプロンプト、カテゴリ、出力フォーマットにより、様々な用途に応用できます：

- 📋 **名簿管理**: 参加者リスト、出欠管理、在籍管理など
- 📊 **データ抽出**: 画像からの情報抽出、OCR処理、帳票読み取りなど
- 🏷️ **分類・フィルタリング**: 条件に基づく自動分類、カテゴリ別管理など
- 📝 **レポート生成**: カスタマイズ可能なフォーマットでのレポート作成
- 🔔 **通知連携**: LINE、Slack、メールなどへの自動通知

### 実用例

**一般的な用途**
- イベント参加者管理
- 出荷・配送管理
- 在庫管理
- アンケート集計
- 帳票処理

### ✨ 主な特徴

- 🤖 **AI画像解析**: Gemini APIを使用した高精度な画像解析
- 🔄 **ワークフロー管理**: 複数のワークフローを定義・保存・切り替え
- 📝 **プロンプトテンプレート**: カスタマイズ可能なプロンプトテンプレート管理
- 🏷️ **カテゴリ管理**: 柔軟なカテゴリ定義とフィルタリング
- 📊 **出力フォーマット**: Markdown、JSON、CSV、カスタムテンプレート対応
- 📱 **クロスプラットフォーム**: iOS、Android、Web対応
- 🔔 **LINE通知**: LINE Messaging API連携による結果通知

## 🚀 クイックスタート

### 前提条件

- Flutter SDK 3.x以上
- Dart SDK 3.x以上
- Google Gemini APIキー
- （オプション）LINE Messaging API設定

### インストール

1. **リポジトリのクローン**

```bash
git clone <repository-url>
cd ai_workflow_builder
```

2. **依存関係のインストール**

```bash
flutter pub get
```

3. **環境変数の設定**

プロジェクトルートに`.env`ファイルを作成：

```env
# 必須: Gemini APIキー
GEMINI_API_KEY=your_gemini_api_key_here

# オプション: 名簿API（Google Sheets連携など）
ROSTER_API_URL=your_roster_api_url_here
ROSTER_API_KEY=your_roster_api_key_here

# オプション: LINE Messaging API
LINE_CHANNEL_ID=your_line_channel_id
LINE_CHANNEL_SECRET=your_line_channel_secret
LINE_CHANNEL_ACCESS_TOKEN=your_line_access_token
LINE_GROUP_ID=your_line_group_id
```

4. **環境変数ファイルの生成**

```bash
dart run build_runner build --delete-conflicting-outputs
```

5. **アプリの実行**

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome
```

## 📱 使い方ガイド

### 基本機能

アプリは3つの主要なタブで構成されています：

1. **データ処理**: 画像から情報を解析し、リストを生成
   - 用途例: 参加者管理、出欠管理、在籍管理、名簿管理など

2. **画像読み取り**: 手書きの書類や帳票を読み取り、報告文を生成
   - 用途例: 帳票処理、OCR、フォーム読み取り、申込書処理など

3. **ワークフロー管理**: カスタマイズ可能なワークフローを作成・管理
   - 用途例: 様々なデータ処理パイプラインの構築

### 1. データ処理の使い方

> **💡 汎用的な用途**  
> この機能は、画像解析とデータ処理を組み合わせて、様々な用途に応用できます。

#### ステップ1: 画像の選択

1. 「データ処理」タブを開く
2. 「スクリーンショットを選択」ボタンをタップ
3. 解析したい画像を1枚以上選択
4. 選択した画像がプレビューに表示されます

#### ステップ2: 名簿の設定

**オフライン名簿を使用する場合:**

1. 「オフライン名簿」を選択
2. 「名簿管理」から既存の名簿を選択、または新規作成
3. 名簿の内容を入力・編集

**Google Sheetsから取得する場合:**

1. 「Google Sheets」を選択
2. シート名を入力
3. APIから名簿データを取得

#### ステップ3: 事前除外・追加設定（オプション）

1. 「事前除外設定」セクションを展開
2. カテゴリごとの除外リストを設定
3. 「事前追加設定」セクションで追加リストを設定
4. 名簿から選択するか、手動で入力

#### ステップ4: リスト生成

1. 「リスト生成」ボタンをタップ
2. AIが画像を解析し、名簿と照合
3. 結果が表示されます

#### ステップ5: 結果の確認・編集

1. 生成された結果を確認
2. 必要に応じて「編集」ボタンで修正
3. 「コピー」でクリップボードにコピー
4. 「共有」で他のアプリに共有

#### ステップ6: LINEに送信（オプション）

1. 「LINEに送信」ボタンをタップ
2. LINE Messaging APIが設定されている場合、自動的に送信されます

### 2. 画像読み取りの使い方

> **💡 汎用的な用途**  
> この機能は、様々な帳票やフォームの読み取りに応用できます。

#### ステップ1: 画像の撮影・選択

1. 「画像読み取り」タブを開く
2. 「カメラで撮影」または「画像を選択」をタップ
3. 読み取りたい書類を撮影・選択

#### ステップ2: 解析実行

1. 「解析実行」ボタンをタップ
2. AIが申込書を読み取り、報告文を生成

#### ステップ3: 結果の確認・編集

1. 生成された報告文を確認
2. 必要に応じて編集
3. コピーまたは共有

### 3. 設定の使い方

#### Geminiモデルの選択

1. 設定画面を開く
2. 「Geminiモデル」を選択
3. 使用するモデルを選択：
   - `gemini-2.5-pro`: 標準モデル
   - `gemini-3-pro-preview`: 最新プレビューモデル

#### プロンプトのカスタマイズ

1. 設定画面で「プロンプト設定」を開く
2. 使用するプロンプトテンプレートを編集
3. プレースホルダーを使用：
   - `%@`: マスター名簿
   - `{SHEET_NAME}`: シート名
   - `{DATE}`: 日付

## 🔧 高度な使い方

### ワークフローの作成

> **💡 カスタマイズについて**  
> プロンプトテンプレート、カテゴリ、出力フォーマットを自由に設定することで、あなたの用途に合わせてカスタマイズできます。

#### 1. プロンプトテンプレートの作成

```dart
// コード例（実際のUIから実行）
final template = PromptTemplate(
  id: 'my-template',
  name: 'マイテンプレート',
  description: 'カスタムプロンプトテンプレート',
  content: '''
あなたは画像解析アシスタントです。
以下の画像を解析してください。

マスター名簿:
{MASTER_ROSTER}

分類:
- カテゴリA: {CONDITION_A}
- カテゴリB: {CONDITION_B}
''',
);
```

**プレースホルダーの形式:**

- `{PLACEHOLDER_NAME}`: 名前付きプレースホルダー（自動検出）
- `%@`: 特殊プレースホルダー（名簿や日付など）

#### 2. カテゴリの定義

```dart
// コード例
final category = Category(
  id: 'category-a',
  name: 'カテゴリA',
  description: '条件Aに一致するアイテム',
  filter: CategoryFilter(
    field: 'status',
    value: 'active',
    type: FilterType.equals,
  ),
);
```

**フィルタータイプ:**

- `equals`: 完全一致
- `contains`: 部分一致
- `startsWith`: 前方一致
- `endsWith`: 後方一致
- `regex`: 正規表現

#### 3. ワークフローの作成

```dart
// コード例
final workflow = Workflow(
  id: 'my-workflow',
  name: 'マイワークフロー',
  description: 'カスタムワークフロー',
  promptTemplateId: 'my-template',
  categories: [category],
  outputFormatId: 'markdown-format',
);
```

#### 4. 出力フォーマットの定義

```dart
// Markdown形式
final markdownFormat = OutputFormat(
  id: 'markdown-format',
  name: 'Markdown',
  description: 'Markdown形式で出力',
  template: '''
# {title}

## カテゴリA
{category_a_items}

## カテゴリB
{category_b_items}
''',
  type: OutputType.markdown,
);

// JSON形式
final jsonFormat = OutputFormat(
  id: 'json-format',
  name: 'JSON',
  description: 'JSON形式で出力',
  template: '',
  type: OutputType.json,
);
```

### データソースの拡張

新しいデータソースを追加するには：

```dart
class MyCustomDataSource implements DataSource {
  @override
  final String id = 'my-custom-source';
  
  @override
  final String name = 'カスタムデータソース';
  
  @override
  final String type = 'custom';
  
  @override
  final String description = 'カスタムデータソースの説明';
  
  @override
  Future<List<DataItem>> fetch() async {
    // データ取得ロジック
    return [];
  }
  
  @override
  Future<void> save(List<DataItem> items) async {
    // データ保存ロジック
  }
  
  @override
  Map<String, dynamic> getConfig() {
    return {'type': type};
  }
  
  @override
  Future<void> updateConfig(Map<String, dynamic> config) async {
    // 設定更新ロジック
  }
}
```

## 🏗️ アーキテクチャ

### ディレクトリ構造

```
lib/
├── models/              # データモデル
│   ├── workflow.dart           # ワークフローモデル
│   ├── category.dart          # カテゴリモデル
│   ├── prompt_template.dart   # プロンプトテンプレート
│   ├── output_format.dart      # 出力フォーマット
│   └── local_roster.dart      # ローカル名簿
├── providers/           # 状態管理（Riverpod）
│   ├── workflow_provider.dart  # ワークフロー管理
│   └── settings_provider.dart  # 設定管理
├── data_sources/        # データソース
│   ├── data_source.dart        # データソース抽象化
│   └── local_roster_data_source.dart
├── services/            # 外部サービス
│   ├── gemini_api_service.dart # Gemini API
│   └── line_messaging_api_service.dart
├── features/            # 機能別画面
│   ├── ship_roaster/          # データ処理
│   ├── boarding_pass/          # 画像読み取り
│   ├── settings/               # 設定
│   └── workflow/               # ワークフロー管理
├── utils/               # ユーティリティ
│   ├── workflow_processor.dart # ワークフロー処理
│   ├── prompt_processor.dart   # プロンプト処理
│   └── date_formatter.dart     # 日付フォーマット
└── widgets/             # 共通ウィジェット
    └── ios_style_button.dart
```

### データフロー

```
ユーザー入力
    ↓
ViewModel（状態管理）
    ↓
Service（API呼び出し）
    ↓
Processor（データ処理）
    ↓
結果表示
```

## 🔐 セキュリティ

### APIキーの管理

- `.env`ファイルにAPIキーを保存
- `.env`ファイルは`.gitignore`に含まれています
- `envied`パッケージを使用して環境変数を管理
- 本番環境では環境変数ファイルを安全に管理してください

### データの保存

- ローカルデータは`SharedPreferences`に保存
- 機密情報は暗号化して保存することを推奨

## 🧪 テスト

### ユニットテストの実行

```bash
# すべてのテストを実行
flutter test

# 特定のテストファイルを実行
flutter test test/utils/date_formatter_test.dart

# カバレッジ付きで実行
flutter test --coverage
```

### テストファイルの場所

テストファイルは`tests_backup`ディレクトリに移動されています。実行するには：

```bash
./run_tests.sh
```

## ⚠️ 免責事項

**本プロジェクトのコードは、本番環境での使用を前提とした包括的なテストを実施していません。**

- 本プロジェクトは実務課題を解決するために開発されたプロトタイプです
- ユニットテスト、統合テスト、E2Eテストなどの包括的なテストスイートは実装されていません
- 一部の機能については開発時の動作確認のみを行っています
- 本番環境で使用する場合は、十分なテストと検証を実施することを強く推奨します
- 本プロジェクトを使用したことによるいかなる損害についても、開発者は責任を負いかねます

**使用する際は自己責任でお願いいたします。**

## 🐛 トラブルシューティング

### よくある問題

#### 1. Gemini APIキーが見つからない

**エラー**: `Gemini API key not found`

**解決方法**:
1. `.env`ファイルに`GEMINI_API_KEY`が設定されているか確認
2. `dart run build_runner build`を実行して環境変数ファイルを再生成

#### 2. 画像解析が失敗する

**原因**: 
- APIキーが無効
- 画像形式が対応していない
- ネットワークエラー

**解決方法**:
1. APIキーを確認
2. 画像形式を確認（JPEG、PNG推奨）
3. ネットワーク接続を確認

#### 3. LINE送信が失敗する

**エラー**: `LINE Messaging APIのトークンが設定されていません`

**解決方法**:
1. `.env`ファイルにLINE Messaging APIの設定を追加
2. チャンネルアクセストークンを取得
3. グループIDが正しく設定されているか確認

#### 4. ビルドエラー

**エラー**: `The sandbox is not in sync with the Podfile.lock`

**解決方法** (iOS):
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

## 📚 ドキュメント

### 日本語版
- [汎用化提案書](GENERALIZATION_PROPOSAL.md)
- [実装ガイド](IMPLEMENTATION_GUIDE.md)
- [移行ガイド](MIGRATION_GUIDE.md)
- [変更サマリー](CHANGES_SUMMARY.md)

### English Version
- [README (English)](README_EN.md)
- [Generalization Proposal (English)](GENERALIZATION_PROPOSAL_EN.md)
- [Implementation Guide (English)](IMPLEMENTATION_GUIDE_EN.md)
- [Migration Guide (English)](MIGRATION_GUIDE_EN.md)
- [Changes Summary (English)](CHANGES_SUMMARY_EN.md)

## 🤝 コントリビューション

コントリビューションを歓迎します！

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をコミット (`git commit -m 'Add some AmazingFeature'`)
4. ブランチにプッシュ (`git push origin feature/AmazingFeature`)
5. プルリクエストを開く

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🙏 謝辞

- [Google Gemini API](https://ai.google.dev/)
- [Flutter](https://flutter.dev/)
- [LINE Messaging API](https://developers.line.biz/ja/docs/messaging-api/)

## 📧 お問い合わせ

質問や問題がある場合は、Issueを作成してください。

---

**AI Workflow Builder** - カスタマイズ可能なAI画像解析ワークフロービルダー
