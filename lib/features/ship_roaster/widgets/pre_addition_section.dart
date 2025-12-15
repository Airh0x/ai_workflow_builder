import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/features/ship_roaster/view_models/ship_roaster_view_model.dart';
import 'package:ai_workflow_builder/providers/settings_provider.dart';
import 'package:ai_workflow_builder/utils/responsive_design.dart';
import 'package:ai_workflow_builder/utils/roster_parser.dart';

class PreAdditionSection extends ConsumerStatefulWidget {
  const PreAdditionSection({super.key});

  @override
  ConsumerState<PreAdditionSection> createState() => _PreAdditionSectionState();
}

class _PreAdditionSectionState extends ConsumerState<PreAdditionSection> {
  bool _isExpanded = false;
  List<String> _addedIslanders = [];
  List<String> _addedReturnees = [];
  List<String> _availableNames = [];

  @override
  void initState() {
    super.initState();
    _loadAdditions();
  }

  Future<void> _loadAdditions() async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final addedIslanders = await settingsNotifier.getAddedIslanders();
    final addedReturnees = await settingsNotifier.getAddedReturnees();
    setState(() {
      _addedIslanders = addedIslanders;
      _addedReturnees = addedReturnees;
    });
    _updateAvailableNames();
  }

  void _updateAvailableNames() {
    final shipRoasterState = ref.read(shipRoasterViewModelProvider);
    if (shipRoasterState.masterRosterText != null) {
      setState(() {
        _availableNames = RosterParser.extractNames(
          shipRoasterState.masterRosterText,
        );
      });
    }
  }

  Future<void> _showIslanderAdditionSelection() async {
    if (_availableNames.isEmpty) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('情報'),
            content: const Text('名簿が読み込まれていません。\n先に名簿を選択してください。'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final result = await showCupertinoModalPopup<List<String>>(
      context: context,
      builder: (context) => _NameSelectionSheet(
        availableNames: _availableNames,
        initialSelected: Set.from(_addedIslanders),
        title: 'カテゴリAに追加する名前を選択',
      ),
    );

    if (result != null) {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      try {
        await settingsNotifier.setAddedIslanders(result);
        await _loadAdditions();
      } catch (e) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('エラー'),
              content: Text('追加設定の保存に失敗しました: $e'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _showReturneeAdditionSelection() async {
    if (_availableNames.isEmpty) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('情報'),
            content: const Text('名簿が読み込まれていません。\n先に名簿を選択してください。'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final result = await showCupertinoModalPopup<List<String>>(
      context: context,
      builder: (context) => _NameSelectionSheet(
        availableNames: _availableNames,
        initialSelected: Set.from(_addedReturnees),
        title: 'カテゴリBに追加する名前を選択',
      ),
    );

    if (result != null) {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      try {
        await settingsNotifier.setAddedReturnees(result);
        await _loadAdditions();
      } catch (e) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('エラー'),
              content: Text('追加設定の保存に失敗しました: $e'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // マスター名簿の変更を監視
    final shipRoasterState = ref.watch(shipRoasterViewModelProvider);
    if (shipRoasterState.masterRosterText != null) {
      final newNames = RosterParser.extractNames(
        shipRoasterState.masterRosterText,
      );
      if (newNames.length != _availableNames.length ||
          !newNames.every((name) => _availableNames.contains(name))) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateAvailableNames();
        });
      }
    }

    return CupertinoListSection.insetGrouped(
      header: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Row(
          children: [
            const Icon(CupertinoIcons.add_circled, size: 18),
            const SizedBox(width: 8),
            Text(
              '事前追加設定 (オプション)',
              style: TextStyle(
                fontSize: ResponsiveDesign.smallFontSize(context),
                fontWeight: FontWeight.w500,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const Spacer(),
            Icon(
              _isExpanded
                  ? CupertinoIcons.chevron_up
                  : CupertinoIcons.chevron_down,
              size: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ],
        ),
      ),
      children: _isExpanded
          ? [
              // 説明文
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveDesign.sectionSpacing(context) * 0.5,
                  vertical: ResponsiveDesign.sectionSpacing(context) * 0.5,
                ),
                child: Text(
                  '処理前に追加したいアイテムを選択できます(空欄でも実行可能)',
                  style: TextStyle(
                    fontSize: ResponsiveDesign.bodyFontSize(context) - 2,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ),
              // カテゴリAとカテゴリBの選択を横並びで表示
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveDesign.sectionSpacing(context) * 0.5,
                ),
                child: Row(
                  children: [
                    // カテゴリAに事前追加
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'カテゴリAに事前追加',
                            style: TextStyle(
                              fontSize: ResponsiveDesign.bodyFontSize(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '追加するアイテムを選択',
                            style: TextStyle(
                              fontSize: ResponsiveDesign.smallFontSize(context),
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showIslanderAdditionSelection,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    ResponsiveDesign.sectionSpacing(context) *
                                    0.75,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors
                                    .secondarySystemGroupedBackground,
                                borderRadius: BorderRadius.circular(
                                  ResponsiveDesign.borderRadius(context),
                                ),
                                border: Border.all(
                                  color: CupertinoColors.separator,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _addedIslanders.isEmpty
                                          ? 'Choose options'
                                          : '${_addedIslanders.length}件選択中',
                                      style: TextStyle(
                                        fontSize: ResponsiveDesign.bodyFontSize(
                                          context,
                                        ),
                                        color: _addedIslanders.isEmpty
                                            ? CupertinoColors.tertiaryLabel
                                            : CupertinoColors.label,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 16,
                                    color: CupertinoColors.tertiaryLabel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveDesign.sectionSpacing(context) * 0.5,
                    ),
                    // カテゴリBに事前追加
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'カテゴリBに事前追加',
                                style: TextStyle(
                                  fontSize: ResponsiveDesign.bodyFontSize(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('カテゴリBに事前追加'),
                                      content: const Text(
                                        'カテゴリBのリストに追加するアイテムを選択できます。',
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Icon(
                                  CupertinoIcons.question_circle,
                                  size: 16,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '追加するアイテムを選択',
                            style: TextStyle(
                              fontSize: ResponsiveDesign.smallFontSize(context),
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showReturneeAdditionSelection,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    ResponsiveDesign.sectionSpacing(context) *
                                    0.75,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors
                                    .secondarySystemGroupedBackground,
                                borderRadius: BorderRadius.circular(
                                  ResponsiveDesign.borderRadius(context),
                                ),
                                border: Border.all(
                                  color: CupertinoColors.separator,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _addedReturnees.isEmpty
                                          ? 'Choose options'
                                          : '${_addedReturnees.length}件選択中',
                                      style: TextStyle(
                                        fontSize: ResponsiveDesign.bodyFontSize(
                                          context,
                                        ),
                                        color: _addedReturnees.isEmpty
                                            ? CupertinoColors.tertiaryLabel
                                            : CupertinoColors.label,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 16,
                                    color: CupertinoColors.tertiaryLabel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]
          : [],
    );
  }
}

/// 名前選択用のシート
class _NameSelectionSheet extends StatefulWidget {
  final List<String> availableNames;
  final Set<String> initialSelected;
  final String title;

  const _NameSelectionSheet({
    required this.availableNames,
    required this.initialSelected,
    required this.title,
  });

  @override
  State<_NameSelectionSheet> createState() => _NameSelectionSheetState();
}

class _NameSelectionSheetState extends State<_NameSelectionSheet> {
  late Set<String> _selectedNames;

  @override
  void initState() {
    super.initState();
    _selectedNames = Set.from(widget.initialSelected);
  }

  void _toggleSelection(String name) {
    setState(() {
      if (_selectedNames.contains(name)) {
        _selectedNames.remove(name);
      } else {
        _selectedNames.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground,
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                  Text(
                    '${widget.title} (${_selectedNames.length}人)',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedNames.toList()),
                    child: const Text(
                      '完了',
                      style: TextStyle(
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // リスト
            Expanded(
              child: ListView.builder(
                itemCount: widget.availableNames.length,
                itemBuilder: (context, index) {
                  final name = widget.availableNames[index];
                  final isSelected = _selectedNames.contains(name);
                  return CupertinoListTile(
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            color: CupertinoColors.systemBlue,
                          )
                        : null,
                    onTap: () => _toggleSelection(name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
