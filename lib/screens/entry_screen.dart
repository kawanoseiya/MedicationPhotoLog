import 'dart:io';

import 'package:flutter/material.dart';

import '../data/photo_store.dart';
import '../debug/demo_mode.dart';
import '../data/record_repository.dart';
import '../l10n/app_localizations.dart';
import '../logic/med_parser.dart';
import '../models/med_record.dart';
import '../services/app_state.dart';
import '../services/review_service.dart';
import '../services/scan_service.dart';
import '../theme.dart';
import '../util/format.dart';
import '../widgets/ui.dart';
import 'photo_viewer.dart';

enum EntrySource { scan, library, manual }

/// 記録の確認・入力・編集。
///
/// 写真があればページごとに端末内で文字を読み、空いている欄にだけ候補を入れる。
/// 利用者が触った欄・消した薬名は、ページを足して読み直しても上書きしない。
/// どの欄も空のまま保存できる。
class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key, this.initialPaths = const [], this.existing});

  /// 撮影・取り込み直後の一時ファイル。
  final List<String> initialPaths;

  /// 編集するときの元の記録。
  final MedRecord? existing;

  /// ホームのボタンから。撮影・取り込みをしてから確認画面を開く。
  static Future<void> start(BuildContext context, EntrySource source) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final paths = switch (source) {
      EntrySource.scan => await ScanService.scan(),
      EntrySource.library => await ScanService.pickFromLibrary(),
      EntrySource.manual => const <String>[],
    };
    if (source != EntrySource.manual && paths.isEmpty) return;
    if (!navigator.mounted) return;
    final saved = await navigator.push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EntryScreen(initialPaths: paths),
      ),
    );
    if (saved != true) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.saved)));
    await ReviewService.instance.recordMeaningfulAction(navigator: navigator);
  }

  /// 詳細画面から。保存したら true。
  static Future<bool> edit(BuildContext context, MedRecord record) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EntryScreen(existing: record),
      ),
    );
    return saved == true;
  }

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

/// 1ページ分の写真。保存前は一時ファイル、保存済みは写真フォルダのファイル名。
class _Page {
  _Page.temp(String this.tempPath) : storedName = null;
  _Page.stored(String this.storedName, this.lines) : tempPath = null;

  final String? tempPath;
  final String? storedName;

  /// 読み取った行。null はまだ読んでいない。
  List<String>? lines;
  bool reading = false;

  File get file =>
      tempPath != null ? File(tempPath!) : PhotoStore.fileSync(storedName!);
}

class _EntryScreenState extends State<EntryScreen> {
  final List<_Page> _pages = [];
  final List<String> _removedStored = [];

  late int _personId;
  DateTime? _date;
  final List<TextEditingController> _medicines = [];
  final _hospital = TextEditingController();
  final _pharmacy = TextEditingController();
  final _memo = TextEditingController();

  bool _dateTouched = false;
  bool _hospitalTouched = false;
  bool _pharmacyTouched = false;

  /// 利用者が消した薬名（読み直しても戻さない）。
  final Set<String> _dismissedMedicines = {};

  /// 読み取りから候補を入れたか（確認の案内を出す）。
  bool _suggested = false;
  bool _dirty = false;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;
  bool get _reading => _pages.any((p) => p.reading);

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    if (r != null) {
      _personId = r.personId;
      _date = r.prescribedOn;
      for (final m in r.medicines) {
        _medicines.add(TextEditingController(text: m));
      }
      _hospital.text = r.hospital;
      _pharmacy.text = r.pharmacy;
      _memo.text = r.memo;
      final ocr = r.ocrPages;
      for (final (i, name) in r.photos.indexed) {
        _pages.add(
          _Page.stored(
            name,
            ocr[i].split('\n').where((l) => l.trim().isNotEmpty).toList(),
          ),
        );
      }
      // 既存の値は利用者が確かめたものとして扱い、候補で上書きしない。
      _dateTouched = r.prescribedOn != null;
      _hospitalTouched = r.hospital.isNotEmpty;
      _pharmacyTouched = r.pharmacy.isNotEmpty;
    } else {
      _personId = AppState.instance.currentPersonId;
      _pages.addAll(widget.initialPaths.map(_Page.temp));
      _dirty = widget.initialPaths.isNotEmpty;
    }
    if (_medicines.isEmpty) _medicines.add(TextEditingController());
    _readPending();
  }

  @override
  void dispose() {
    for (final c in _medicines) {
      c.dispose();
    }
    _hospital.dispose();
    _pharmacy.dispose();
    _memo.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- 読み取り

  Future<void> _readPending() async {
    final pending = _pages.where((p) => p.lines == null && !p.reading).toList();
    if (pending.isEmpty) return;
    setState(() {
      for (final p in pending) {
        p.reading = true;
      }
    });
    for (final page in pending) {
      final lines = await ScanService.recognize(page.file.path);
      if (!mounted) return;
      setState(() {
        page.lines = lines;
        page.reading = false;
      });
      _applySuggestions();
    }
  }

  static String _medKey(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s'), '');

  void _applySuggestions() {
    final lines = [for (final p in _pages) ...?p.lines];
    if (lines.isEmpty) return;
    final parsed = MedParser.parse(lines);
    DemoMode.dumpOcr(lines, parsed);
    var changed = false;
    if (!_dateTouched && _date == null && parsed.prescribedOn != null) {
      _date = parsed.prescribedOn;
      changed = true;
    }
    if (!_hospitalTouched && _hospital.text.isEmpty && parsed.hospital != '') {
      _hospital.text = parsed.hospital;
      changed = true;
    }
    if (!_pharmacyTouched && _pharmacy.text.isEmpty && parsed.pharmacy != '') {
      _pharmacy.text = parsed.pharmacy;
      changed = true;
    }
    final have = {for (final c in _medicines) _medKey(c.text)};
    for (final name in parsed.medicines) {
      final key = _medKey(name);
      if (have.contains(key) || _dismissedMedicines.contains(key)) continue;
      // 空の入力欄があればそこに入れる。
      final empty = _medicines.where((c) => c.text.trim().isEmpty).firstOrNull;
      if (empty != null) {
        empty.text = name;
      } else {
        _medicines.add(TextEditingController(text: name));
      }
      have.add(key);
      changed = true;
    }
    if (changed) {
      setState(() {
        _suggested = true;
        _dirty = true;
      });
    }
  }

  // ---------------------------------------------------------------- ページ

  Future<void> _addPages() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<EntrySource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, EntrySource.scan),
                icon: const Icon(Icons.document_scanner_rounded),
                label: Text(l10n.addByCamera),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, EntrySource.library),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.addFromLibrary),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final paths = source == EntrySource.scan
        ? await ScanService.scan()
        : await ScanService.pickFromLibrary();
    if (paths.isEmpty || !mounted) return;
    setState(() {
      _pages.addAll(paths.map(_Page.temp));
      _dirty = true;
    });
    await _readPending();
  }

  Future<void> _removePage(_Page page) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirm(
      context,
      title: l10n.removePageTitle,
      message: l10n.removePageBody,
      confirmLabel: l10n.remove,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _pages.remove(page);
      if (page.storedName != null) _removedStored.add(page.storedName!);
      _dirty = true;
    });
    if (page.tempPath != null) _deleteTemp([page]);
  }

  void _deleteTemp(Iterable<_Page> pages) {
    for (final p in pages) {
      if (p.tempPath == null) continue;
      File(p.tempPath!).delete().catchError((_) => File(p.tempPath!));
    }
  }

  // ---------------------------------------------------------------- 入力

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateTouched = true;
      _dirty = true;
    });
  }

  void _removeMedicine(int index) {
    setState(() {
      final c = _medicines.removeAt(index);
      if (c.text.trim().isNotEmpty) _dismissedMedicines.add(_medKey(c.text));
      c.dispose();
      if (_medicines.isEmpty) _medicines.add(TextEditingController());
      _dirty = true;
    });
  }

  Future<void> _pickPerson() async {
    final state = AppState.instance;
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final p in state.persons)
                ListTile(
                  minTileHeight: 60,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(p.name, style: const TextStyle(fontSize: 19)),
                  trailing: p.id == _personId
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 28,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, p.id),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      _personId = picked;
      _dirty = true;
    });
  }

  // ---------------------------------------------------------------- 保存

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    final adopted = <String>[];
    try {
      final names = <String>[];
      for (final page in _pages) {
        if (page.storedName != null) {
          names.add(page.storedName!);
        } else {
          final name = await PhotoStore.adopt(page.tempPath!);
          adopted.add(name);
          names.add(name);
        }
      }
      final now = DateTime.now();
      final medicines = [
        for (final c in _medicines)
          if (c.text.trim().isNotEmpty)
            c.text.trim().replaceAll(RegExp(r'\s*\n\s*'), ' '),
      ];
      final ocrText = MedRecord.joinOcrPages([
        for (final p in _pages) (p.lines ?? const []).join('\n'),
      ]);
      final repo = RecordRepository.instance;
      final existing = widget.existing;
      if (existing == null) {
        await repo.insert(
          MedRecord(
            personId: _personId,
            prescribedOn: _date,
            medicines: medicines,
            hospital: _hospital.text.trim(),
            pharmacy: _pharmacy.text.trim(),
            memo: _memo.text.trim(),
            ocrText: ocrText,
            photos: names,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await repo.update(
          existing.copyWith(
            personId: _personId,
            prescribedOn: _date,
            clearPrescribedOn: _date == null,
            medicines: medicines,
            hospital: _hospital.text.trim(),
            pharmacy: _pharmacy.text.trim(),
            memo: _memo.text.trim(),
            ocrText: ocrText,
            photos: names,
            updatedAt: now,
          ),
        );
        await PhotoStore.deleteAll(_removedStored);
      }
      await AppState.instance.notifyDataChanged();
      if (!mounted) return;
      Navigator.pop(context, true);
    } on Exception catch (e) {
      debugPrint('保存できませんでした: $e');
      // 写真フォルダへ移した分は記録に紐づかないので消す。
      await PhotoStore.deleteAll(adopted);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final l10n = AppLocalizations.of(context);
    return showConfirm(
      context,
      title: l10n.discardTitle,
      message: l10n.discardBody,
      confirmLabel: l10n.discard,
      cancelLabel: l10n.keepEditing,
      destructive: true,
    );
  }

  Future<void> _close() async {
    if (!await _confirmDiscard() || !mounted) return;
    _deleteTemp(_pages);
    Navigator.pop(context, false);
  }

  // ---------------------------------------------------------------- 画面

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = AppState.instance;
    final person = state.persons.where((p) => p.id == _personId).firstOrNull;
    final ocrLines = [
      for (final (i, p) in _pages.indexed)
        if ((p.lines ?? const []).isNotEmpty) ...[
          if (_pages.length > 1) '— ${l10n.pageNumber(i + 1)} —',
          ...p.lines!,
        ],
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l10n.close,
            icon: const Icon(Icons.close_rounded, size: 28),
            onPressed: _close,
          ),
          title: Text(_isEdit ? l10n.editRecordTitle : l10n.newRecordTitle),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.only(top: 4, bottom: 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              _pagesStrip(l10n),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _reading
                    ? NoticeBanner(
                        icon: Icons.hourglass_top_rounded,
                        text: l10n.readingText,
                      )
                    : _suggested
                    ? NoticeBanner(
                        icon: Icons.fact_check_outlined,
                        tone: NoticeTone.caution,
                        text: l10n.checkSuggestions,
                      )
                    : NoticeBanner(
                        icon: Icons.info_outline_rounded,
                        text: _pages.isEmpty ? l10n.manualHint : l10n.blankIsOk,
                      ),
              ),
              if (state.persons.length > 1)
                Group(
                  children: [
                    GroupRow(
                      icon: Icons.person_rounded,
                      title: l10n.fieldPerson,
                      value: person?.name ?? '',
                      onTap: _pickPerson,
                    ),
                  ],
                ),
              _label(l10n.fieldDate),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.inner),
                          onTap: _pickDate,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 58),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.subtle,
                              borderRadius: BorderRadius.circular(
                                AppRadius.inner,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.event_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _date == null
                                        ? l10n.dateNotSet
                                        : formatDate(context, _date!),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: _date == null
                                          ? AppColors.textSecondary
                                          : AppColors.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_date != null)
                      IconButton(
                        tooltip: l10n.clearDate,
                        icon: const Icon(Icons.backspace_outlined),
                        onPressed: () => setState(() {
                          _date = null;
                          _dateTouched = true;
                          _dirty = true;
                        }),
                      ),
                  ],
                ),
              ),
              _label(l10n.fieldMedicines),
              for (final (i, c) in _medicines.indexed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 4, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: c,
                          style: const TextStyle(fontSize: 18),
                          minLines: 1,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: l10n.medicineHint,
                            prefixIcon: const Icon(Icons.medication_outlined),
                          ),
                          onChanged: (_) => _dirty = true,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.removeMedicine,
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => _removeMedicine(i),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _medicines.add(TextEditingController());
                      _dirty = true;
                    }),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addMedicine),
                  ),
                ),
              ),
              _label(l10n.fieldHospital),
              _field(
                _hospital,
                icon: Icons.local_hospital_outlined,
                onChanged: () => _hospitalTouched = true,
              ),
              _label(l10n.fieldPharmacy),
              _field(
                _pharmacy,
                icon: Icons.storefront_outlined,
                onChanged: () => _pharmacyTouched = true,
              ),
              _label(l10n.fieldMemo),
              _field(_memo, multiline: true),
              if (ocrLines.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _OcrPanel(
                    title: l10n.fieldOcrText,
                    text: ocrLines.join('\n'),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(l10n.save),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    ),
  );

  Widget _field(
    TextEditingController c, {
    IconData? icon,
    bool multiline = false,
    VoidCallback? onChanged,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
    child: TextField(
      controller: c,
      style: const TextStyle(fontSize: 18),
      minLines: multiline ? 3 : 1,
      maxLines: multiline ? 8 : 2,
      decoration: InputDecoration(prefixIcon: icon == null ? null : Icon(icon)),
      onChanged: (_) {
        _dirty = true;
        onChanged?.call();
      },
    ),
  );

  Widget _pagesStrip(AppLocalizations l10n) {
    return SizedBox(
      height: 196,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final (i, page) in _pages.indexed)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _PageThumb(
                page: page,
                label: l10n.pageNumber(i + 1),
                removeLabel: l10n.removePageTitle,
                onTap: () => PhotoViewer.open(context, [
                  for (final p in _pages) p.file,
                ], initialIndex: i),
                onRemove: () => _removePage(page),
              ),
            ),
          Semantics(
            button: true,
            label: l10n.addPage,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.inner),
              onTap: _addPages,
              child: Container(
                width: 132,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.inner),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_a_photo_outlined,
                      size: 36,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _pages.isEmpty ? l10n.addPhoto : l10n.addPage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageThumb extends StatelessWidget {
  const _PageThumb({
    required this.page,
    required this.label,
    required this.removeLabel,
    required this.onTap,
    required this.onRemove,
  });

  final _Page page;
  final String label;
  final String removeLabel;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            button: true,
            label: label,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.inner),
                child: ColoredBox(
                  color: AppColors.track,
                  child: Image.file(
                    page.file,
                    fit: BoxFit.cover,
                    cacheWidth: 420,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
          ),
          if (page.reading)
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.inner),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            left: 8,
            bottom: 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: IconButton(
              tooltip: removeLabel,
              onPressed: onRemove,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.close_rounded, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

/// 読み取った文字の全文（折りたたみ）。
class _OcrPanel extends StatelessWidget {
  const _OcrPanel({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.group),
      child: ColoredBox(
        color: AppColors.subtle,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 18),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            leading: const Icon(Icons.text_snippet_outlined),
            title: Text(title, style: const TextStyle(fontSize: 18)),
            expandedAlignment: Alignment.topLeft,
            children: [
              SelectableText(
                text,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
