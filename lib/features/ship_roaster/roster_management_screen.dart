import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/features/ship_roaster/add_edit_roster_screen.dart';
import 'package:ai_workflow_builder/features/ship_roaster/view_models/ship_roaster_view_model.dart';
import 'package:ai_workflow_builder/utils/responsive_design.dart';

class RosterManagementScreen extends ConsumerWidget {
  const RosterManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shipRoasterViewModelProvider);
    final viewModel = ref.read(shipRoasterViewModelProvider.notifier);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('オフライン名簿管理'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.add_circled),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const AddEditRosterScreen(),
                    ),
                  );
                },
              ),
            ),
            SliverSafeArea(
              top: false,
              sliver: state.savedRosters.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: ResponsiveDesign.padding(context),
                          child: Text(
                            '名簿がありません。\n右上の「+」ボタンから追加してください。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: ResponsiveDesign.bodyFontSize(context),
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: ResponsiveDesign.padding(context),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final roster = state.savedRosters[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  ResponsiveDesign.sectionSpacing(context) *
                                  0.75,
                            ),
                            child: CupertinoListTile(
                              title: Text(
                                roster.name,
                                style: TextStyle(
                                  fontSize: ResponsiveDesign.bodyFontSize(
                                    context,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                roster.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveDesign.bodyFontSize(context) -
                                      2,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => AddEditRosterScreen(
                                      rosterToEdit: roster,
                                    ),
                                  ),
                                );
                              },
                              trailing: CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  color: CupertinoColors.destructiveRed,
                                ),
                                onPressed: () {
                                  viewModel.deleteRoster(roster.id);
                                },
                              ),
                            ),
                          );
                        }, childCount: state.savedRosters.length),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
