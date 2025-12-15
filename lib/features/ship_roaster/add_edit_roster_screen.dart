import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/features/ship_roaster/view_models/ship_roaster_view_model.dart';
import 'package:ai_workflow_builder/models/local_roster.dart';
import 'package:ai_workflow_builder/utils/responsive_design.dart';

class AddEditRosterScreen extends ConsumerStatefulWidget {
  final LocalRoster? rosterToEdit;

  const AddEditRosterScreen({super.key, this.rosterToEdit});

  @override
  ConsumerState<AddEditRosterScreen> createState() =>
      _AddEditRosterScreenState();
}

class _AddEditRosterScreenState extends ConsumerState<AddEditRosterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _contentFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.rosterToEdit?.name ?? '',
    );
    _contentController = TextEditingController(
      text: widget.rosterToEdit?.content ?? '',
    );
    _nameFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _nameFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _saveRoster() {
    if (_nameController.text.isEmpty || _contentController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('エラー'),
          content: const Text('名前と内容を入力してください'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final viewModel = ref.read(shipRoasterViewModelProvider.notifier);

    final roster = LocalRoster(
      id: widget.rosterToEdit?.id,
      name: _nameController.text,
      content: _contentController.text,
    );
    viewModel.addRoster(roster);

    Navigator.of(context).pop();
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
              largeTitle: Text(
                widget.rosterToEdit == null ? '新規名簿の作成' : '名簿を編集',
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveRoster,
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
                        CupertinoTextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          placeholder: '名簿の名前',
                          padding: EdgeInsets.all(
                            ResponsiveDesign.sectionSpacing(context),
                          ),
                          style: TextStyle(
                            fontSize: ResponsiveDesign.bodyFontSize(context),
                          ),
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            // 名前フィールドから次のフィールドへフォーカス移動
                            _contentFocusNode.requestFocus();
                          },
                          enableInteractiveSelection: true,
                          clearButtonMode: OverlayVisibilityMode.never,
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveDesign.sectionSpacing(context)),
                    CupertinoListSection.insetGrouped(
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height * 0.3,
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
                            controller: _contentController,
                            focusNode: _contentFocusNode,
                            placeholder: '名簿の内容',
                            maxLines: null,
                            minLines: 15,
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(
                              fontSize: ResponsiveDesign.bodyFontSize(context),
                              height: 1.5,
                            ),
                            padding: EdgeInsets.all(
                              ResponsiveDesign.sectionSpacing(context) * 0.75,
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
                    ),
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
