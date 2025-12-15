import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_workflow_builder/features/main_tab/main_tab_view.dart';
import 'package:ai_workflow_builder/utils/app_initializer.dart';

/// アプリケーションのエントリーポイント
Future<void> main() async {
  // 非同期処理のための初期化
  WidgetsFlutterBinding.ensureInitialized();

  // APIキーの読み込みと検証
  await AppInitializer.validateApiKeys();

  // Riverpodを使用するために、アプリ全体をProviderScopeでラップ
  runApp(const ProviderScope(child: MyApp()));
}

/// アプリケーションのルートウィジェット
/// 
/// HIG準拠のCupertinoAppを使用して、iOSネイティブな
/// ユーザーインターフェースを提供します。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'AI Workflow Builder',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: const MainTabView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
