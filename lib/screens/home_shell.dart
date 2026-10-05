import 'package:flutter/material.dart';

import '../debug/demo_mode.dart';
import '../l10n/app_localizations.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/person_switcher.dart';
import '../widgets/ui.dart';
import 'entry_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// 下部の「ホーム」「履歴」タブ。上部に誰の記録かの切り替えと設定。
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = DemoMode.startTab.clamp(0, 1);

  @override
  void initState() {
    super.initState();
    if (DemoMode.entryImage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final path = await DemoMode.copyToTemp(DemoMode.entryImage);
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => EntryScreen(initialPaths: [path]),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 12, 10),
              child: Row(
                children: [
                  const Flexible(child: PersonSwitcher()),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.settings_rounded, size: 22),
                    label: Text(l10n.settings),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [
                  HomeScreen(onShowAll: () => setState(() => _index = 1)),
                  const HistoryScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdSlot(),
          AppTabBar(
            index: _index,
            onChanged: (i) => setState(() => _index = i),
            items: [
              (Icons.home_outlined, Icons.home_rounded, l10n.tabHome),
              (
                Icons.view_agenda_outlined,
                Icons.view_agenda_rounded,
                l10n.tabHistory,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
