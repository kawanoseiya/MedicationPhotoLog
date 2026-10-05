import 'dart:async';

import 'package:flutter/material.dart';

import '../data/record_repository.dart';
import '../l10n/app_localizations.dart';
import '../models/med_record.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../util/format.dart';
import '../widgets/record_tile.dart';
import '../widgets/ui.dart';
import 'detail_screen.dart';

/// 履歴。新しい順に月ごとにまとめ、薬名・医療機関・薬局・読み取った文字で検索できる。
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<MedRecord>? _records;
  int _loadedRevision = -1;
  int _loadedPerson = -1;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onState);
    _load();
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onState);
    _debounce?.cancel();
    _search.dispose();
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
    final request = ++_request;
    final records = await RecordRepository.instance.recordsFor(
      s.currentPersonId,
      query: _search.text,
    );
    // 入力が続いたときは最後の検索結果だけを出す。
    if (!mounted || request != _request) return;
    setState(() => _records = records);
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _load);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final records = _records;
    final searching = _search.text.trim().isNotEmpty;

    // 月ごとの見出しを挟む。
    final children = <Widget>[];
    if (records != null) {
      String? month;
      var group = <Widget>[];
      void flush() {
        if (month == null || group.isEmpty) return;
        children.add(Group(header: month, children: group));
        group = <Widget>[];
      }

      for (final r in records) {
        final m = formatMonth(context, r.sortDate);
        if (m != month) {
          flush();
          month = m;
        }
        group.add(
          RecordTile(record: r, onTap: () => DetailScreen.open(context, r.id!)),
        );
      }
      flush();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            controller: _search,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searching
                  ? IconButton(
                      tooltip: l10n.clearSearch,
                      icon: const Icon(Icons.cancel_rounded),
                      onPressed: () {
                        _search.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: records == null
              ? const SizedBox.shrink()
              : records.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    NoticeBanner(
                      icon: searching
                          ? Icons.search_off_rounded
                          : Icons.info_outline_rounded,
                      text: searching ? l10n.noSearchResults : l10n.homeEmpty,
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    children: [
                      if (searching)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                          child: Text(
                            l10n.searchResultCount(records.length),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ...children,
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
