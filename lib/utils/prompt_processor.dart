import 'package:ai_workflow_builder/providers/settings_provider.dart';
import 'package:ai_workflow_builder/utils/date_formatter.dart';

/// プロンプトテンプレートの処理を担当するクラス
class PromptProcessor {
  PromptProcessor._(); // インスタンス化を防ぐ

  /// プロンプトテンプレートを処理して、プレースホルダーを置換する
  ///
  /// [settingsNotifier] 設定プロバイダー
  /// [promptKey] プロンプトのキー
  /// [masterRoster] マスター名簿の内容（オプション）
  /// [sheetName] シート名（オプション）
  /// [isBoardingPass] 画像読み取り用のプロンプトかどうか
  /// [excludedPassengers] 除外するアイテムのリスト（オプション）
  /// [addedPassengers] 追加するアイテムのリスト（オプション）
  static Future<String> processPrompt(
    SettingsNotifier settingsNotifier,
    String promptKey, {
    String? masterRoster,
    String? sheetName,
    bool isBoardingPass = false,
    List<String>? excludedPassengers,
    List<String>? addedPassengers,
  }) async {
    final promptTemplate = settingsNotifier.getPrompt(promptKey);

    // デフォルトプロンプトが空の場合はデフォルトを使用
    final effectivePrompt = promptTemplate.isEmpty
        ? settingsNotifier.getDefaultPrompt(promptKey)
        : promptTemplate;

    var processedPrompt = effectivePrompt;

    if (isBoardingPass) {
      // 画像読み取り用: 日付のプレースホルダーを置換
      final formattedDate = DateFormatter.formatBoardingPassDate();
      processedPrompt = processedPrompt.replaceAll('%@', formattedDate);
    } else {
      // データ処理用: プロンプトの先頭に翌日の日付を追加
      final nextDayDate = DateFormatter.formatNextDayWithWeekday();
      processedPrompt = '$nextDayDate\n\n$processedPrompt';

      // マスター名簿のプレースホルダーを置換
      // 注意: テンプレート内に%@が2箇所あるが、1つ目（マスター名簿部分）のみ置換
      if (masterRoster != null) {
        processedPrompt = processedPrompt.replaceFirst('%@', masterRoster);
      }

      // {SHEET_NAME}を選択されたシート名に置換
      if (sheetName != null) {
        processedPrompt = processedPrompt.replaceAll('{SHEET_NAME}', sheetName);
      }

      // 除外リストと追加リストをプロンプトに追加
      final excludedList =
          excludedPassengers ?? await settingsNotifier.getExcludedPassengers();
      final addedList =
          addedPassengers ?? await settingsNotifier.getAddedPassengers();

      // カテゴリごとの除外リストと追加リストを取得
      final excludedIslanders = await settingsNotifier.getExcludedIslanders();
      final excludedReturnees = await settingsNotifier.getExcludedReturnees();
      final addedIslanders = await settingsNotifier.getAddedIslanders();
      final addedReturnees = await settingsNotifier.getAddedReturnees();

      String additionalInstructions = '';

      // カテゴリごとの除外ルール
      if (excludedIslanders.isNotEmpty || excludedReturnees.isNotEmpty) {
        additionalInstructions += '''

# 事前除外ルール
''';
        if (excludedIslanders.isNotEmpty) {
          final islanderNames = excludedIslanders.join('、');
          additionalInstructions +=
              '''
- **カテゴリAから除外**: 以下の名前のアイテムは、カテゴリAのリストから**必ず除外**してください。
  除外する名前: $islanderNames

''';
        }
        if (excludedReturnees.isNotEmpty) {
          final returneeNames = excludedReturnees.join('、');
          additionalInstructions +=
              '''
- **カテゴリBから除外**: 以下の名前のアイテムは、カテゴリBのリストから**必ず除外**してください。
  除外する名前: $returneeNames

''';
        }
        additionalInstructions += '''
重要: これらの名前は、画像から読み取った情報やマスター名簿に含まれていても、指定されたカテゴリからは一切含めないでください。
''';
      }

      // カテゴリごとの追加ルール
      if (addedIslanders.isNotEmpty || addedReturnees.isNotEmpty) {
        additionalInstructions += '''

# 事前追加ルール
''';
        if (addedIslanders.isNotEmpty) {
          final islanderNames = addedIslanders.join('、');
          additionalInstructions +=
              '''
- **カテゴリAに追加**: 以下の名前のアイテムは、画像から読み取った情報に含まれていなくても、マスター名簿に含まれていれば、カテゴリAのリストに**必ず含めて**ください。
  追加する名前: $islanderNames

''';
        }
        if (addedReturnees.isNotEmpty) {
          final returneeNames = addedReturnees.join('、');
          additionalInstructions +=
              '''
- **カテゴリBに追加**: 以下の名前のアイテムは、画像から読み取った情報に含まれていなくても、マスター名簿に含まれていれば、カテゴリBのリストに**必ず含めて**ください。
  追加する名前: $returneeNames

''';
        }
        additionalInstructions += '''
重要: これらの名前は、マスター名簿に含まれていて、画像から読み取った情報に含まれていなくても、指定されたカテゴリに含めてください。
''';
      }

      if (excludedList.isNotEmpty) {
        final excludedNames = excludedList.join('、');
        additionalInstructions +=
            '''

# 除外ルール
以下の名前のアイテムは、マスター名簿に含まれていても、最終的なレポートから**必ず除外**してください。
除外する名前: $excludedNames

重要: これらの名前は、画像から読み取った情報やマスター名簿に含まれていても、最終的なレポートには一切含めないでください。
''';
      }

      if (addedList.isNotEmpty) {
        final addedNames = addedList.join('、');
        additionalInstructions +=
            '''

# 追加ルール
以下の名前のアイテムは、画像から読み取った情報に含まれていなくても、マスター名簿に含まれていれば、最終的なレポートに**必ず含めて**ください。
追加する名前: $addedNames

重要: これらの名前は、マスター名簿に含まれていて、画像から読み取った情報に含まれていなくても、最終的なレポートに含めてください。
''';
      }

      if (additionalInstructions.isNotEmpty) {
        // マスター名簿のセクションの後にルールを追加
        processedPrompt = processedPrompt.replaceFirst(
          '# 出力フォーマット例',
          '$additionalInstructions\n# 出力フォーマット例',
        );
      }
    }

    return processedPrompt;
  }
}
