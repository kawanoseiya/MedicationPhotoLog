import 'package:flutter/material.dart';

import '../data/record_repository.dart';
import '../l10n/app_localizations.dart';
import '../models/med_record.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/record_tile.dart';
import '../widgets/ui.dart';
import 'detail_screen.dart';
import 'entry_screen.dart';

/// ホーム。大きな「撮って記録」ボタンと、直近の記録。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _recentCount = 5;

  List<MedRecord>? _recent;
  int _total = 0;
  int _loadedRevision = -1;
  int _loadedPerson = -1;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onState);
    _load();
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onState);
    super.dispose();
  }

  void _onState() {
    final s = AppState.instance;
    if (s.dataRevision != _loadedRevision ||
        s.currentPersonId != _loadedPerson) {
      _load();
    }
  }

  Future<void> _load() async {
    final s = AppState.instance;
    _loadedRevision = s.dataRevision;
    _loadedPerson = s.currentPersonId;
    final repo = RecordRepository.instance;
    final recent = await repo.recordsFor(
      s.currentPersonId,
      limit: _recentCount,
    );
    final total = await repo.countFor(s.currentPersonId);
    if (!mounted) return;
    setState(() {
      _recent = recent;
      _total = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recent = _recent;
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _CaptureButton(
            label: l10n.captureButton,
            caption: l10n.captureCaption,
            onTap: () => EntryScreen.start(context, EntrySource.scan),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      EntryScreen.start(context, EntrySource.library),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: FittedBox(child: Text(l10n.importPhotos)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      EntryScreen.start(context, EntrySource.manual),
                  icon: const Icon(Icons.edit_outlined),
                  label: FittedBox(child: Text(l10n.manualEntry)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (recent == null)
          const SizedBox.shrink()
        else if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NoticeBanner(
              icon: Icons.info_outline_rounded,
              text: l10n.homeEmpty,
            ),
          )
        else
          Group(
            header: l10n.recentRecords,
            children: [
              for (final r in recent)
                RecordTile(
                  record: r,
                  onTap: () => DetailScreen.open(context, r.id!),
                ),
              if (_total > recent.length)
                GroupRow(
                  icon: Icons.view_agenda_outlined,
                  title: l10n.showAllRecords(_total),
                  onTap: widget.onShowAll,
                ),
            ],
          ),
      ],
    );
  }
}

/// 画面の主役のボタン。押しやすい大きさと、何をするかの短い説明。
class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label。$caption',
      excludeSemantics: true,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.group),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.group),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              children: [
                const Icon(
                  Icons.document_scanner_rounded,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
