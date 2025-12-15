import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/providers/settings_provider.dart';
import 'package:ai_workflow_builder/utils/responsive_design.dart';

class ModelSelectionScreen extends ConsumerWidget {
  const ModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentModel = settingsNotifier.getGeminiModel();
    final availableModels = settingsNotifier.getAvailableGeminiModels();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('Geminiモデル選択'),
            ),
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: ResponsiveDesign.padding(context),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    CupertinoListSection.insetGrouped(
                      header: Text(
                        '使用するモデルを選択',
                        style: TextStyle(
                          fontSize: ResponsiveDesign.smallFontSize(context),
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      children: [
                        for (final model in availableModels)
                          CupertinoListTile(
                            title: Text(model),
                            trailing: currentModel == model
                                ? const Icon(
                                    CupertinoIcons.check_mark,
                                    color: CupertinoColors.systemBlue,
                                  )
                                : null,
                            onTap: () async {
                              await settingsNotifier.updateGeminiModel(model);
                              // モデルを変更したので、GeminiApiServiceのモデルをリセット
                              // （次回のAPI呼び出し時に新しいモデルが使用される）
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: ResponsiveDesign.sectionSpacing(context)),
                    CupertinoListSection.insetGrouped(
                      header: Text(
                        'モデル情報',
                        style: TextStyle(
                          fontSize: ResponsiveDesign.smallFontSize(context),
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(ResponsiveDesign.sectionSpacing(context)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'gemini-2.5-pro',
                                style: TextStyle(
                                  fontSize: ResponsiveDesign.bodyFontSize(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: ResponsiveDesign.sectionSpacing(context) * 0.5),
                              Text(
                                '安定版のGemini 2.5 Proモデルです。',
                                style: TextStyle(
                                  fontSize: ResponsiveDesign.bodyFontSize(context) - 2,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                              SizedBox(height: ResponsiveDesign.sectionSpacing(context)),
                              Text(
                                'gemini-3-pro-preview',
                                style: TextStyle(
                                  fontSize: ResponsiveDesign.bodyFontSize(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: ResponsiveDesign.sectionSpacing(context) * 0.5),
                              Text(
                                '最新のGemini 3 Pro Previewモデルです。より高度な機能を提供します。',
                                style: TextStyle(
                                  fontSize: ResponsiveDesign.bodyFontSize(context) - 2,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveDesign.sectionSpacing(context) * 5), // Bottom padding
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

