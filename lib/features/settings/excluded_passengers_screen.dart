import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/features/ship_roaster/view_models/ship_roaster_view_model.dart';
import 'package:ai_workflow_builder/providers/settings_provider.dart';
import 'package:ai_workflow_builder/utils/responsive_design.dart';
import 'package:ai_workflow_builder/utils/roster_parser.dart';

class ExcludedPassengersScreen extends ConsumerStatefulWidget {
  const ExcludedPassengersScreen({super.key});

  @override
  ConsumerState<ExcludedPassengersScreen> createState() =>
      _ExcludedPassengersScreenState();
}

class _ExcludedPassengersScreenState
    extends ConsumerState<ExcludedPassengersScreen> {
  List<String> _excludedPassengers = [];
  List<String> _addedPassengers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPassengers();
  }

  Future<void> _loadPassengers() async {
    setState(() => _isLoading = true);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final excludedList = await settingsNotifier.getExcludedPassengers();
    final addedList = await settingsNotifier.getAddedPassengers();
    setState(() {
      _excludedPassengers = excludedList;
      _addedPassengers = addedList;
      _isLoading = false;
    });
  }

  Future<void> _removeExcludedPassenger(String name) async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    try {
      await settingsNotifier.removeExcludedPassenger(name);
      await _loadPassengers();
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('エラー'),
            content: Text('除外乗船者の削除に失敗しました: $e'),
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

  Future<void> _removeAddedPassenger(String name) async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    try {
      await settingsNotifier.removeAddedPassenger(name);
      await _loadPassengers();
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('エラー'),
            content: Text('追加乗船者の削除に失敗しました: $e'),
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

  Future<void> _clearExcluded() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('確認'),
        content: const Text('全ての除外乗船者を削除しますか？'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      try {
        await settingsNotifier.clearExcludedPassengers();
        await _loadPassengers();
      } catch (e) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('エラー'),
              content: Text('除外乗船者の削除に失敗しました: $e'),
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

  Future<void> _clearAdded() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('確認'),
        content: const Text('全ての追加乗船者を削除しますか？'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      try {
        await settingsNotifier.clearAddedPassengers();
        await _loadPassengers();
      } catch (e) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('エラー'),
              content: Text('追加乗船者の削除に失敗しました: $e'),
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

  Future<void> _showNameSelectionSheet(
    List<String> availableNames,
    bool isExcluded,
  ) async {
    if (availableNames.isEmpty) return;

    // 既にリストに含まれている名前を除外
    final currentList = isExcluded ? _excludedPassengers : _addedPassengers;
    final selectableNames = availableNames
        .where((name) => !currentList.contains(name))
        .toList();

    if (selectableNames.isEmpty) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('情報'),
            content: Text(
              isExcluded
                  ? '選択可能な名前がありません。\n全ての名前が既に除外リストに含まれています。'
                  : '選択可能な名前がありません。\n全ての名前が既に追加リストに含まれています。',
            ),
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
        availableNames: selectableNames,
        initialSelected: <String>{},
        title: isExcluded ? '除外する名前を選択' : '追加する名前を選択',
      ),
    );

    if (result != null && result.isNotEmpty) {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      try {
        for (final name in result) {
          if (isExcluded) {
            await settingsNotifier.addExcludedPassenger(name);
          } else {
            await settingsNotifier.addPassenger(name);
          }
        }
        await _loadPassengers();
      } catch (e) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('エラー'),
              content: Text(
                isExcluded
                    ? '除外乗船者の追加に失敗しました: $e'
                    : '追加乗船者の追加に失敗しました: $e',
              ),
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
    // マスター名簿の変更を監視して利用可能な名前を取得
    final shipRoasterState = ref.watch(shipRoasterViewModelProvider);
    final availableNames = shipRoasterState.masterRosterText != null
        ? RosterParser.extractNames(shipRoasterState.masterRosterText)
        : <String>[];

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('乗船者管理'),
            ),
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: ResponsiveDesign.padding(context),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 名簿から選択セクション
                    if (availableNames.isNotEmpty)
                      CupertinoListSection.insetGrouped(
                        header: Text(
                          '名簿から選択',
                          style: TextStyle(
                            fontSize: ResponsiveDesign.smallFontSize(context),
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              color: CupertinoColors.destructiveRed.withValues(
                                alpha: 0.1,
                              ),
                              onPressed: () =>
                                  _showNameSelectionSheet(availableNames, true),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.minus_circle,
                                    size: ResponsiveDesign.iconSize(context) *
                                        0.9,
                                    color: CupertinoColors.destructiveRed,
                                  ),
                                  SizedBox(
                                    width: ResponsiveDesign.sectionSpacing(
                                      context,
                                    ) *
                                        0.5,
                                  ),
                                  Text(
                                    '除外する名前を選択',
                                    style: TextStyle(
                                      fontSize: ResponsiveDesign.bodyFontSize(
                                        context,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.destructiveRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              color: CupertinoColors.systemGreen.withValues(
                                alpha: 0.1,
                              ),
                              onPressed: () =>
                                  _showNameSelectionSheet(availableNames, false),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.add_circled,
                                    size: ResponsiveDesign.iconSize(context) *
                                        0.9,
                                    color: CupertinoColors.systemGreen,
                                  ),
                                  SizedBox(
                                    width: ResponsiveDesign.sectionSpacing(
                                      context,
                                    ) *
                                        0.5,
                                  ),
                                  Text(
                                    '追加する名前を選択',
                                    style: TextStyle(
                                      fontSize: ResponsiveDesign.bodyFontSize(
                                        context,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.systemGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (availableNames.isNotEmpty)
                      SizedBox(
                        height: ResponsiveDesign.sectionSpacing(context),
                      ),
                    // 説明セクション
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveDesign.sectionSpacing(context) * 0.5,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(
                          ResponsiveDesign.sectionSpacing(context),
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.secondarySystemGroupedBackground,
                          borderRadius: BorderRadius.circular(
                            ResponsiveDesign.borderRadius(context),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  CupertinoIcons.info_circle,
                                  size: ResponsiveDesign.iconSize(context) * 0.8,
                                  color: CupertinoColors.systemBlue,
                                ),
                                SizedBox(
                                  width: ResponsiveDesign.sectionSpacing(context) *
                                      0.5,
                                ),
                                Expanded(
                                  child: Text(
                                    '除外リスト: 結果から除外する乗船者\n追加リスト: 結果に必ず含める乗船者',
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveDesign.bodyFontSize(context) -
                                              2,
                                      color: CupertinoColors.secondaryLabel,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveDesign.sectionSpacing(context),
                    ),
                    // 除外リストセクション
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      )
                    else ...[
                      CupertinoListSection.insetGrouped(
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '除外リスト (${_excludedPassengers.length}人)',
                              style: TextStyle(
                                fontSize: ResponsiveDesign.smallFontSize(context),
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                            if (_excludedPassengers.isNotEmpty)
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _clearExcluded,
                                child: const Text(
                                  '全削除',
                                  style: TextStyle(
                                    color: CupertinoColors.destructiveRed,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        children: _excludedPassengers.isEmpty
                            ? [
                                Padding(
                                  padding: EdgeInsets.all(
                                    ResponsiveDesign.sectionSpacing(context),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '除外する乗船者はいません',
                                      style: TextStyle(
                                        fontSize: ResponsiveDesign.bodyFontSize(
                                          context,
                                        ),
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                            : [
                                for (final name in _excludedPassengers)
                                  CupertinoListTile(
                                    title: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: ResponsiveDesign.bodyFontSize(
                                          context,
                                        ),
                                      ),
                                    ),
                                    trailing: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () =>
                                          _removeExcludedPassenger(name),
                                      child: const Icon(
                                        CupertinoIcons.delete,
                                        color: CupertinoColors.destructiveRed,
                                      ),
                                    ),
                                  ),
                              ],
                      ),
                      SizedBox(
                        height: ResponsiveDesign.sectionSpacing(context),
                      ),
                      // 追加リストセクション
                      CupertinoListSection.insetGrouped(
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '追加リスト (${_addedPassengers.length}人)',
                              style: TextStyle(
                                fontSize: ResponsiveDesign.smallFontSize(context),
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                            if (_addedPassengers.isNotEmpty)
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _clearAdded,
                                child: const Text(
                                  '全削除',
                                  style: TextStyle(
                                    color: CupertinoColors.destructiveRed,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        children: _addedPassengers.isEmpty
                            ? [
                                Padding(
                                  padding: EdgeInsets.all(
                                    ResponsiveDesign.sectionSpacing(context),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '追加する乗船者はいません',
                                      style: TextStyle(
                                        fontSize: ResponsiveDesign.bodyFontSize(
                                          context,
                                        ),
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                            : [
                                for (final name in _addedPassengers)
                                  CupertinoListTile(
                                    title: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: ResponsiveDesign.bodyFontSize(
                                          context,
                                        ),
                                      ),
                                    ),
                                    trailing: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () =>
                                          _removeAddedPassenger(name),
                                      child: const Icon(
                                        CupertinoIcons.delete,
                                        color: CupertinoColors.destructiveRed,
                                      ),
                                    ),
                                  ),
                              ],
                      ),
                    ],
                    SizedBox(
                      height: ResponsiveDesign.sectionSpacing(context) * 2,
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
                    onPressed: _selectedNames.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(_selectedNames.toList()),
                    child: Text(
                      '追加',
                      style: TextStyle(
                        color: _selectedNames.isEmpty
                            ? CupertinoColors.tertiaryLabel
                            : CupertinoColors.systemBlue,
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
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
