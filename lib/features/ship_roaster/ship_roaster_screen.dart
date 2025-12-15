import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/features/common_widgets/edit_result_screen.dart';
import 'package:ai_workflow_builder/features/settings/excluded_passengers_screen.dart';
import 'package:ai_workflow_builder/features/settings/model_selection_screen.dart';
import 'package:ai_workflow_builder/features/settings/settings_screen.dart';
import 'package:ai_workflow_builder/features/workflow/workflows_screen.dart';
import 'package:ai_workflow_builder/features/workflow/prompt_templates_screen.dart';
import 'package:ai_workflow_builder/features/workflow/categories_screen.dart';
import 'package:ai_workflow_builder/features/workflow/output_formats_screen.dart';
import 'package:ai_workflow_builder/features/ship_roaster/view_models/ship_roaster_view_model.dart';
import 'package:ai_workflow_builder/features/ship_roaster/widgets/image_preview.dart';
import 'package:ai_workflow_builder/features/ship_roaster/widgets/pre_exclusion_section.dart';
import 'package:ai_workflow_builder/features/ship_roaster/widgets/pre_addition_section.dart';
import 'package:ai_workflow_builder/features/ship_roaster/widgets/roster_selection_card.dart';
import 'package:ai_workflow_builder/features/ship_roaster/widgets/status_bar.dart';
import 'package:ai_workflow_builder/providers/settings_provider.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';
import 'package:ai_workflow_builder/widgets/ios_style_button.dart';

class ShipRoasterScreen extends ConsumerWidget {
  const ShipRoasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModelの状態とロジックへの参照を取得
    final shipRoasterState = ref.watch(shipRoasterViewModelProvider);
    final shipRoasterViewModel = ref.read(
      shipRoasterViewModelProvider.notifier,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(
                  largeTitle: const Text('データ処理'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.refresh),
                        onPressed: () => shipRoasterViewModel.resetInputs(),
                      ),
                      if (shipRoasterState.resultText.isNotEmpty) ...[
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.doc_on_clipboard),
                          onPressed: () =>
                              shipRoasterViewModel.copyResultToClipboard(),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.share),
                          onPressed: () => shipRoasterViewModel.shareResult(),
                        ),
                      ],
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.settings),
                        onPressed: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) => CupertinoActionSheet(
                              title: const Text('設定'),
                              actions: [
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) => SettingsScreen(
                                          promptKey: ref.read(
                                            shipRoasterPromptKeyProvider,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('プロンプト設定'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            const ModelSelectionScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Geminiモデル選択'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            const ExcludedPassengersScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('乗船者管理'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) => const WorkflowsScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('ワークフロー管理'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            const PromptTemplatesScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('プロンプトテンプレート'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            const CategoriesScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('カテゴリ管理'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            const OutputFormatsScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('出力フォーマット'),
                                ),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                onPressed: () => Navigator.of(context).pop(),
                                isDefaultAction: true,
                                child: const Text('キャンセル'),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SliverSafeArea(
                  top: false,
                  sliver: SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingStandard,
                      vertical: AppTheme.paddingStandard,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Section: 名簿の選択
                        const RosterSelectionCard(),
                        const SizedBox(height: AppTheme.sectionSpacing),
                        // Section: 事前除外設定
                        const PreExclusionSection(),
                        const SizedBox(height: AppTheme.sectionSpacing),
                        // Section: 事前追加設定
                        const PreAdditionSection(),
                        const SizedBox(height: AppTheme.sectionSpacing),
                        // Section: スクリーンショットを選択
                        CupertinoListSection.insetGrouped(
                          header: Text(
                            'スクリーンショットを選択',
                            style: AppTheme.footnote(context),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.paddingCompact,
                                vertical: AppTheme.paddingCompact,
                              ),
                              child: IOSStyleButton(
                                text: shipRoasterState.selectedImages.isEmpty
                                    ? 'スクリーンショットを選択'
                                    : '${shipRoasterState.selectedImages.length}枚の画像を選択中',
                                icon: CupertinoIcons.photo_on_rectangle,
                                style: IOSButtonStyle.primary,
                                semanticLabel:
                                    shipRoasterState.selectedImages.isEmpty
                                    ? 'スクリーンショットを選択する'
                                    : '${shipRoasterState.selectedImages.length}枚の画像が選択されています',
                                onPressed: () =>
                                    shipRoasterViewModel.pickImages(),
                              ),
                            ),
                          ],
                        ),
                        if (shipRoasterState.selectedImages.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.sectionSpacing),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.sectionSpacing * 0.5,
                            ),
                            child: ImagePreview(
                              images: shipRoasterState.selectedImages,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.sectionSpacing),
                        // Section: 実行
                        IOSActionButton(
                          text: '乗船者リストを作成',
                          icon: CupertinoIcons.rocket,
                          style: IOSButtonStyle.secondary,
                          isLoading: shipRoasterState.isProcessing,
                          semanticLabel: '乗船者リストを作成する',
                          onPressed: shipRoasterState.isProcessing
                              ? null
                              : () => shipRoasterViewModel.generateList(),
                        ),
                        const SizedBox(height: AppTheme.sectionSpacing),
                        // Section: 結果
                        if (shipRoasterState.resultText.isNotEmpty)
                          CupertinoListSection.insetGrouped(
                            header: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('作成結果', style: AppTheme.footnote(context)),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.pencil,
                                        size: AppTheme.iconSizeSmall,
                                      ),
                                      const SizedBox(
                                        width: AppTheme.paddingCompact,
                                      ),
                                      Text(
                                        '編集',
                                        style: AppTheme.caption1(context),
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    final editedText =
                                        await Navigator.of(
                                          context,
                                        ).push<String>(
                                          CupertinoPageRoute(
                                            builder: (_) => EditResultScreen(
                                              initialText:
                                                  shipRoasterState.resultText,
                                            ),
                                          ),
                                        );
                                    if (editedText != null) {
                                      shipRoasterViewModel.updateResultText(
                                        editedText,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(
                                  AppTheme.sectionSpacing,
                                ),
                                child: SelectableText(
                                  shipRoasterState.resultText,
                                  style: AppTheme.body(
                                    context,
                                  ).copyWith(height: 1.5),
                                ),
                              ),
                              // LINE送信ボタン
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.sectionSpacing * 0.5,
                                  vertical: AppTheme.sectionSpacing * 0.5,
                                ),
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    return FutureBuilder<bool>(
                                      future: ref
                                          .read(settingsProvider.notifier)
                                          .isLineMessagingApiEnabled(),
                                      builder: (context, snapshot) {
                                        final isEnabled =
                                            snapshot.data ?? false;
                                        if (!isEnabled) {
                                          return const SizedBox.shrink();
                                        }
                                        return IOSActionButton(
                                          text: 'LINEに送信',
                                          icon: CupertinoIcons.paperplane_fill,
                                          style: IOSButtonStyle.primary,
                                          isLoading:
                                              shipRoasterState.isProcessing,
                                          semanticLabel: 'LINEに送信する',
                                          onPressed:
                                              shipRoasterState.isProcessing
                                              ? null
                                              : () => shipRoasterViewModel
                                                    .sendToLine(),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        // コピーライトと情報メッセージ
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 16,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.info_circle,
                                    size: AppTheme.iconSizeStandard * 0.7,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                  const SizedBox(
                                    width: AppTheme.sectionSpacing * 0.5,
                                  ),
                                  Flexible(
                                    child: Text(
                                      shipRoasterState.selectedImages.isEmpty ||
                                              shipRoasterState
                                                      .masterRosterText ==
                                                  null
                                          ? '用地名簿と乗船者リストを設定して下さい。'
                                          : '準備が整いました。乗船者リストを作成してください。',
                                      style: AppTheme.subheadline(context),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: AppTheme.sectionSpacing * 2,
                        ), // Bottom padding for status bar
                      ]),
                    ),
                  ),
                ),
              ],
            ),
            if (shipRoasterState.isProcessing)
              Container(
                color: CupertinoColors.black.withValues(alpha: 0.3),
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: AppTheme.iconSizeLarge,
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: StatusBar(
                message: shipRoasterState.statusMessage,
                type: shipRoasterState.statusType,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
