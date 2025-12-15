/// アプリケーション全体で使用する定数
class AppConstants {
  AppConstants._(); // インスタンス化を防ぐ

  // デフォルト値
  static const String defaultSheetName = '2Z';
  static const String defaultRosterFilename = '名簿を選択';
  static const String defaultStatusMessage = '名簿とスクショを選択してください';
  static const String defaultBoardingPassStatusMessage = '画像を選択してください';

  // SharedPreferences キー
  static const String savedRostersKey = 'savedRostersData';

  // エラーメッセージ
  static const String errorNoRosterOrImages = 'エラー：名簿またはスクショが選択されていません。';
  static const String errorNoImages = 'エラー：画像が選択されていません。';
  static const String errorApiFailed = '❌ APIエラーが発生しました';
  static const String errorNetworkFailed = '❌ ネットワークエラー';
  static const String errorEnvNotConfigured =
      'APIのURLまたはキーが.envファイルに設定されていません。';
  static const String errorGeminiApiKeyNotFound =
      'GEMINI_API_KEY not found in .env file';

  // 成功メッセージ
  static const String successListCreated = '✅ リストが作成されました。内容は確認してください。';
  static const String successRosterFetched = '✅ 名簿を取得しました。';
  static const String successReadingCompleted = '✅ 読み取りが完了しました';
  static const String successCopiedToClipboard = '📋 クリップボードにコピーしました！';
  static const String successImagesSelected = '✅ %d枚の画像を選択しました';
  static const String successImagesPrepared = '✅ %d枚の画像を準備しました';

  // 処理中メッセージ
  static const String processingCreating = '🚢 作成中...';
  static const String processingReading = '画像を読み取っています...';
  static const String processingFetchingRoster = '名簿を取得中...';

  // ヒントメッセージ
  static const String hintBuildRunner =
      '   ヒント: dart run build_runner build を実行してenv.g.dartを生成してください';
}
