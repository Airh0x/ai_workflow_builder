import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/features/ship_roaster/roster_management_screen.dart';
import 'package:ai_workflow_builder/features/ship_roaster/view_models/ship_roaster_view_model.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';
import 'package:ai_workflow_builder/widgets/ios_style_button.dart';

class RosterSelectionCard extends ConsumerWidget {
  const RosterSelectionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shipflowViewModelProvider);
    final viewModel = ref.read(shipflowViewModelProvider.notifier);

    return Semantics(
      header: true,
      child: CupertinoListSection.insetGrouped(
        header: Text(
          '名簿の選択',
          style: AppTheme.footnote(context),
        ),
      children: [
        // 用地名の選択
        Semantics(
          label: '用地名: ${state.selectedSheetName}',
          button: true,
          child: CupertinoListTile(
            title: Text('用地名', style: AppTheme.body(context)),
            subtitle: Text(
              '集合場所の表示に使用されます',
              style: AppTheme.subheadline(context),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.selectedSheetName,
                    style: AppTheme.body(context),
                  ),
                  const SizedBox(width: AppTheme.paddingCompact),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    size: AppTheme.iconSizeSmall,
                  ),
                ],
              ),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => CupertinoActionSheet(
                  title: const Text('用地名を選択'),
                  actions: [
                    for (final sheetName in [
                      '2Z',
                      '3G',
                      '3J',
                      '4I',
                      '4E',
                      '6A',
                    ])
                      CupertinoActionSheetAction(
                        onPressed: () {
                          viewModel.setSheetName(sheetName);
                          Navigator.of(context).pop();
                        },
                        child: Text(sheetName),
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
          ),
        ),
        // 名簿ソースの選択
        Semantics(
          label: '名簿の取得方法',
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingStandard,
              vertical: AppTheme.paddingCompact,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.paddingCompact),
                  child: Text(
                    '名簿の取得方法',
                    style: AppTheme.footnote(context),
                  ),
                ),
                CupertinoSegmentedControl<RosterSource>(
                  children: const {
                    RosterSource.localFile: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingCompact,
                        vertical: 4,
                      ),
                      child: Text('オフライン'),
                    ),
                    RosterSource.googleSheet: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingCompact,
                        vertical: 4,
                      ),
                      child: Text('オンライン'),
                    ),
                  },
                  groupValue: state.selectedRosterSource,
                  onValueChanged: (value) {
                    viewModel.setRosterSource(value);
                  },
                ),
              ],
            ),
          ),
        ),
        // Conditional UI based on selection
        if (state.selectedRosterSource == RosterSource.localFile)
          ..._buildLocalRosterSelector(context, state, viewModel)
        else
          _buildOnlineRosterSelector(context, state, viewModel),
        // 選択された名簿の表示
        if (state.masterRosterText != null)
          Semantics(
            label: '選択された名簿: ${state.masterRosterFilename}',
            child: CupertinoListTile(
              leading: const Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: CupertinoColors.systemGreen,
                size: AppTheme.iconSizeStandard,
              ),
              title: Text(
                state.masterRosterFilename,
                style: AppTheme.body(context).copyWith(
                  fontWeight: AppTheme.fontWeightSemibold,
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ),
          ),
      ],
      ),
    );
  }

  List<Widget> _buildLocalRosterSelector(
    BuildContext context,
    ShipRoasterState state,
    ShipRoasterViewModel viewModel,
  ) {
    return [
      if (state.savedRosters.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingStandard,
            vertical: AppTheme.paddingCompact,
          ),
          child: Text(
            '名簿がありません。下のボタンから追加してください。',
            style: AppTheme.subheadline(context),
          ),
        )
      else
        Semantics(
          label: state.selectedRosterId != null
              ? '保存済み名簿: ${state.savedRosters.firstWhere((r) => r.id == state.selectedRosterId).name}'
              : '保存済み名簿: 選択してください',
          button: true,
          child: CupertinoListTile(
            title: Text('保存済み名簿', style: AppTheme.body(context)),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.selectedRosterId != null
                        ? state.savedRosters
                              .firstWhere((r) => r.id == state.selectedRosterId)
                              .name
                        : '選択してください',
                    style: AppTheme.body(context).copyWith(
                      color: state.selectedRosterId != null
                          ? CupertinoColors.label
                          : CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingCompact),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    size: AppTheme.iconSizeSmall,
                  ),
                ],
              ),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => CupertinoActionSheet(
                  title: const Text('名簿を選択'),
                  actions: [
                    for (final roster in state.savedRosters)
                      CupertinoActionSheetAction(
                        onPressed: () {
                          viewModel.selectRosterById(roster.id);
                          Navigator.of(context).pop();
                        },
                        child: Text(roster.name),
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
          ),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingCompact,
          vertical: AppTheme.paddingCompact,
        ),
        child: IOSStyleButton(
          text: 'オフライン名簿を管理',
          icon: CupertinoIcons.list_bullet_indent,
          style: IOSButtonStyle.primary,
          semanticLabel: 'オフライン名簿を管理する',
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => const RosterManagementScreen(),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildOnlineRosterSelector(
    BuildContext context,
    ShipRoasterState state,
    ShipRoasterViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingCompact,
        vertical: AppTheme.paddingCompact,
      ),
      child: IOSStyleButton(
        text: state.isLoadingRoster ? '取得中...' : 'オンライン名簿を取得',
        icon: CupertinoIcons.cloud_download,
        style: IOSButtonStyle.primary,
        isLoading: state.isLoadingRoster,
        semanticLabel: 'オンライン名簿を取得する',
        onPressed: state.isLoadingRoster
            ? null
            : () => viewModel.fetchRosterFromNetwork(),
      ),
    );
  }
}

// ViewModel Provider (for convenience, referencing the main one)
final shipflowViewModelProvider = shipRoasterViewModelProvider;
