import 'package:flutter/cupertino.dart';
import 'package:ai_workflow_builder/features/boarding_pass/boarding_pass_screen.dart';
import 'package:ai_workflow_builder/features/ship_roaster/ship_roaster_screen.dart';
import 'package:ai_workflow_builder/features/workflow/workflows_screen.dart';
import 'package:ai_workflow_builder/theme/app_theme.dart';

/// メインタブビュー
///
/// HIG準拠のタブバーを使用して、アプリの主要画面を切り替えます。
class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  static const List<Widget> _screens = [
    ShipRoasterScreen(),
    BoardingPassScreen(),
    WorkflowsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        iconSize: AppTheme.iconSizeStandard,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_list),
            label: 'データ処理',
            activeIcon: Icon(CupertinoIcons.square_list_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            label: '画像読み取り',
            activeIcon: Icon(CupertinoIcons.doc_text_fill),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'ワークフロー',
            activeIcon: Icon(CupertinoIcons.settings_solid),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            if (index >= 0 && index < _screens.length) {
              return _screens[index];
            }
            return _screens[0];
          },
        );
      },
    );
  }
}
