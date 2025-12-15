import 'package:ai_workflow_builder/models/workflow.dart';
import 'package:ai_workflow_builder/models/prompt_template.dart';
import 'package:ai_workflow_builder/models/output_format.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/utils/date_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ワークフロープロセッサー
/// 
/// 汎用化のためのワークフロー処理
class WorkflowProcessor {
  WorkflowProcessor._(); // インスタンス化を防ぐ

  /// ワークフローに基づいてプロンプトを処理
  ///
  /// [ref] Riverpodの参照
  /// [workflow] 使用するワークフロー
  /// [data] 追加データ（マスター名簿、シート名など）
  static Future<String> processWorkflowPrompt(
    Ref ref,
    Workflow workflow, {
    Map<String, String>? data,
  }) async {
    // プロンプトテンプレートを取得
    final templates = ref.read(promptTemplateProvider);
    final template = templates.firstWhere(
      (t) => t.id == workflow.promptTemplateId,
      orElse: () => PromptTemplate(
        id: workflow.promptTemplateId,
        name: 'Default',
        description: 'Default template',
        content: 'プロンプトテンプレートが見つかりません',
      ),
    );

    // プレースホルダーを置換
    final placeholders = <String, String>{};

    // 日付の追加
    placeholders['DATE'] = DateFormatter.formatNextDayWithWeekday();
    placeholders['BOARDING_DATE'] = DateFormatter.formatBoardingPassDate();

    // カスタムデータの追加
    if (data != null) {
      placeholders.addAll(data);
    }

    // マスター名簿の処理
    if (data != null && data.containsKey('MASTER_ROSTER')) {
      placeholders['%@'] = data['MASTER_ROSTER']!;
    }

    // シート名の処理
    if (data != null && data.containsKey('SHEET_NAME')) {
      placeholders['SHEET_NAME'] = data['SHEET_NAME']!;
    }

    // カテゴリごとの除外/追加ルールを追加
    final categoryNotifier = ref.read(categoryProvider.notifier);
    await categoryNotifier.loadCategories(workflow.id);

    String additionalInstructions = '';

    for (final category in workflow.categories) {
      final excluded = await categoryNotifier.getExcludedItems(
        workflow.id,
        category.id,
      );
      final added = await categoryNotifier.getAddedItems(
        workflow.id,
        category.id,
      );

      if (excluded.isNotEmpty) {
        final excludedNames = excluded.join('、');
        additionalInstructions +=
            '''
- **【${category.name}】セクションから除外**: 以下の名前は、${category.name}リストから**必ず除外**してください。
  除外する名前: $excludedNames

''';
      }

      if (added.isNotEmpty) {
        final addedNames = added.join('、');
        additionalInstructions +=
            '''
- **【${category.name}】セクションに追加**: 以下の名前は、マスター名簿に含まれていれば、${category.name}リストに**必ず含めて**ください。
  追加する名前: $addedNames

''';
      }
    }

    // プロンプトを処理
    var processedPrompt = template.replacePlaceholders(placeholders);

    // 追加の指示を挿入
    if (additionalInstructions.isNotEmpty) {
      processedPrompt = processedPrompt.replaceFirst(
        '# 分類ルール',
        '$additionalInstructions\n# 分類ルール',
      );
    }

    return processedPrompt;
  }

  /// ワークフローに基づいて出力をフォーマット
  ///
  /// [ref] Riverpodの参照
  /// [workflow] 使用するワークフロー
  /// [data] 出力データ
  static String formatOutput(
    Ref ref,
    Workflow workflow,
    Map<String, dynamic> data,
  ) {
    if (workflow.outputFormatId == null) {
      // デフォルトのMarkdown形式
      return _formatDefaultMarkdown(data);
    }

    final formatNotifier = ref.read(outputFormatProvider.notifier);
    final format = formatNotifier.getFormat(workflow.outputFormatId!);

    if (format == null) {
      return _formatDefaultMarkdown(data);
    }

    return format.render(data);
  }

  /// デフォルトのMarkdown形式でフォーマット
  static String _formatDefaultMarkdown(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    if (data.containsKey('title')) {
      buffer.writeln('# ${data['title']}');
      buffer.writeln();
    }

    if (data.containsKey('categories')) {
      final categories = data['categories'] as Map<String, dynamic>?;
      if (categories != null) {
        for (final entry in categories.entries) {
          buffer.writeln('## ${entry.key}');
          final items = entry.value as List<dynamic>?;
          if (items != null && items.isNotEmpty) {
            for (final item in items) {
              buffer.writeln('- $item');
            }
          }
          buffer.writeln();
        }
      }
    }

    return buffer.toString();
  }
}

