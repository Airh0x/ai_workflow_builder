import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/features/boarding_pass/camera_screen.dart';
import 'package:ai_workflow_builder/features/boarding_pass/view_models/boarding_pass_view_model.dart';
import 'package:ai_workflow_builder/features/common_widgets/edit_result_screen.dart';
import 'package:ai_workflow_builder/features/settings/model_selection_screen.dart';
import 'package:ai_workflow_builder/features/settings/settings_screen.dart';
import 'package:ai_workflow_builder/features/ship_roaster/widgets/image_preview.dart';
import 'package:ai_workflow_builder/features/ship_roaster/widgets/status_bar.dart';
import 'package:ai_workflow_builder/providers/settings_provider.dart';
import 'package:ai_workflow_builder/utils/responsive_design.dart';
import 'package:ai_workflow_builder/widgets/ios_style_button.dart';

class BoardingPassScreen extends ConsumerWidget {
  const BoardingPassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(boardingPassViewModelProvider);
    final viewModel = ref.read(boardingPassViewModelProvider.notifier);

    // Listen for errors and show a dialog
    ref.listen<BoardingPassState>(boardingPassViewModelProvider, (
      previous,
      next,
    ) {
      if (next.isShowingErrorAlert) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('エラー'),
            content: Text(next.errorMessage ?? '不明なエラーが発生しました。'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  viewModel.dismissErrorAlert();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    });

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(
                  largeTitle: const Text('画像読み取り'),
                  leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.refresh),
                    onPressed: () => viewModel.resetInputs(),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.resultText.isNotEmpty)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.share),
                          onPressed: () => viewModel.shareResult(),
                        ),
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
                                            boardingPassPromptKeyProvider,
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
                    padding: ResponsiveDesign.padding(context),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Section: 画像の選択
                        CupertinoListSection.insetGrouped(
                          header: Text(
                            '画像の選択',
                            style: TextStyle(
                              fontSize: ResponsiveDesign.smallFontSize(context),
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          children: [
                            CupertinoListTile(
                              title: const Text('アルバム'),
                              leading: const Icon(
                                CupertinoIcons.photo_on_rectangle,
                              ),
                              onTap: () => viewModel.pickImages(),
                            ),
                            CupertinoListTile(
                              title: const Text('カメラ'),
                              leading: const Icon(CupertinoIcons.camera),
                              onTap: () async {
                                final newImages = await Navigator.of(context)
                                    .push<List<XFile>>(
                                      CupertinoPageRoute(
                                        builder: (_) => const CameraScreen(),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                if (newImages != null && newImages.isNotEmpty) {
                                  viewModel.addImages(newImages);
                                }
                              },
                            ),
                          ],
                        ),
                        if (state.selectedImages.isNotEmpty) ...[
                          SizedBox(
                            height: ResponsiveDesign.sectionSpacing(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ImagePreview(images: state.selectedImages),
                          ),
                        ],
                        SizedBox(
                          height: ResponsiveDesign.sectionSpacing(context),
                        ),
                        // Section: 実行
                        IOSActionButton(
                          text: '画像を読み取る',
                          icon: CupertinoIcons.doc_text_search,
                          style: IOSButtonStyle.secondary,
                          isLoading: state.isProcessing,
                          onPressed:
                              state.isProcessing || state.selectedImages.isEmpty
                              ? null
                              : () => viewModel.generateReport(),
                        ),
                        SizedBox(
                          height: ResponsiveDesign.sectionSpacing(context),
                        ),
                        // Section: 結果
                        if (state.resultText.isNotEmpty)
                          CupertinoListSection.insetGrouped(
                            header: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '読み取り結果',
                                  style: TextStyle(
                                    fontSize: ResponsiveDesign.smallFontSize(
                                      context,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(CupertinoIcons.pencil, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        '編集',
                                        style: TextStyle(fontSize: 13),
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
                                              initialText: state.resultText,
                                            ),
                                          ),
                                        );
                                    if (editedText != null) {
                                      viewModel.updateResultText(editedText);
                                    }
                                  },
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                  ResponsiveDesign.sectionSpacing(context),
                                ),
                                child: SelectableText(
                                  state.resultText,
                                  style: TextStyle(
                                    fontSize: ResponsiveDesign.bodyFontSize(
                                      context,
                                    ),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: ResponsiveDesign.sectionSpacing(context) * 2,
                        ), // Bottom padding for status bar
                      ]),
                    ),
                  ),
                ),
              ],
            ),
            if (state.isProcessing)
              Container(
                color: CupertinoColors.black.withValues(alpha: 0.3),
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: ResponsiveDesign.iconSize(context) * 1.2,
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: StatusBar(
                message: state.statusMessage,
                type: state.statusType,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
