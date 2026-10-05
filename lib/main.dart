import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/photo_store.dart';
import 'debug/demo_mode.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_shell.dart';
import 'services/ad_service.dart';
import 'services/app_state.dart';
import 'services/purchase_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await PhotoStore.init();
  await AppState.instance.load();
  if (DemoMode.enabled) await DemoMode.seedIfEmpty();
  runApp(const SnapMedApp());
  // 購入状態の確認は起動を待たせない。確認できるまでは保存済みの状態を使う。
  // デモ用ビルドでは購入確認をしない（シミュレータでサインイン画面が出る）。
  if (!DemoMode.enabled) {
    PurchaseService.instance.init().then((_) => AdService.instance.init());
  }
}

class SnapMedApp extends StatelessWidget {
  const SnapMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        themeMode: ThemeMode.light,
        locale: state.language.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          // システムの文字サイズに、設定の「文字表示」を上乗せする。
          final media = MediaQuery.of(context);
          final system = media.textScaler.scale(16) / 16;
          final scale = (system * state.textSize.scale).clamp(1.0, 3.0);
          return MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          );
        },
        home: const HomeShell(),
      ),
    );
  }
}
