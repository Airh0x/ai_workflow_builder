import 'package:flutter/cupertino.dart';
import 'package:ai_workflow_builder/utils/responsive_design.dart';

class EditResultScreen extends StatefulWidget {
  final String initialText;

  const EditResultScreen({super.key, required this.initialText});

  @override
  State<EditResultScreen> createState() => _EditResultScreenState();
}

class _EditResultScreenState extends State<EditResultScreen> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('結果を編集'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).pop(_textController.text);
                },
                child: const Text('完了'),
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
                            controller: _textController,
                            maxLines: null,
                            minLines: 20,
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(
                              fontSize: ResponsiveDesign.bodyFontSize(context),
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
