import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/providers/settings_provider.dart';
import 'package:ai_workflow_builder/utils/responsive_design.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final String promptKey;

  const SettingsScreen({super.key, required this.promptKey});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _promptController;
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // ref.read can be used in initState for the initial value
    final initialPrompt = ref
        .read(settingsProvider.notifier)
        .getPrompt(widget.promptKey);
    _promptController = TextEditingController(text: initialPrompt);
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ref
        .read(settingsProvider.notifier)
        .updatePrompt(widget.promptKey, _promptController.text);
    Navigator.of(context).pop();
    // Cupertinoスナックバーの代わりに、簡単な通知を表示
    // 実際のアプリでは、CupertinoAlertDialogや別の方法を使用することを推奨
  }

  void _resetPrompt() {
    final defaultPrompt = ref
        .read(settingsProvider.notifier)
        .getDefaultPrompt(widget.promptKey);
    _promptController.text = defaultPrompt;
  }

  @override
  Widget build(BuildContext context) {
    // パフォーマンス改善: ref.watchを削除して不要な再構築を防ぐ
    // 初期値はinitStateで設定済み、保存時のみproviderを更新
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('プロンプト設定'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveSettings,
                child: const Text('保存'),
              ),
            ),
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: ResponsiveDesign.padding(context),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    CupertinoListSection.insetGrouped(
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          padding: EdgeInsets.all(
                            ResponsiveDesign.sectionSpacing(context),
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors
                                .secondarySystemGroupedBackground,
                            borderRadius: BorderRadius.circular(
                              ResponsiveDesign.borderRadius(context),
                            ),
                          ),
                          child: CupertinoTextField(
                            controller: _promptController,
                            focusNode: _focusNode,
                            maxLines: null,
                            minLines: 20,
                            textAlignVertical: TextAlignVertical.top,
                            placeholder: 'プロンプトの編集',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize:
                                  ResponsiveDesign.bodyFontSize(context) - 2,
                              height: 1.5,
                            ),
                            padding: EdgeInsets.all(
                              ResponsiveDesign.sectionSpacing(context) * 0.75,
                            ),
                            scrollController: _scrollController,
                            scrollPadding: EdgeInsets.all(
                              ResponsiveDesign.sectionSpacing(context) * 0.5,
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            enableInteractiveSelection: true,
                            clearButtonMode: OverlayVisibilityMode.never,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveDesign.sectionSpacing(context)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveDesign.sectionSpacing(context) * 0.5,
                      ),
                      child: SizedBox(
                        height: ResponsiveDesign.buttonHeight(context),
                        child: CupertinoButton(
                          color: CupertinoColors.destructiveRed,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveDesign.sectionSpacing(
                              context,
                            ),
                            vertical: 12,
                          ),
                          onPressed: _resetPrompt,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.refresh,
                                size: ResponsiveDesign.iconSize(context) * 0.9,
                              ),
                              SizedBox(
                                width:
                                    ResponsiveDesign.sectionSpacing(context) *
                                    0.5,
                              ),
                              Text(
                                '初期化(リセット)',
                                style: TextStyle(
                                  fontSize: ResponsiveDesign.bodyFontSize(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveDesign.sectionSpacing(context) * 5,
                    ), // Bottom padding
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
