import 'package:flutter/material.dart';

import '../data/photo_store.dart';
import '../data/record_repository.dart';
import '../l10n/app_localizations.dart';
import '../models/med_record.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../util/format.dart';
import '../widgets/ui.dart';
import 'entry_screen.dart';
import 'photo_viewer.dart';

/// 記録の詳細。元の写真と、保存した項目・読み取った文字。
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.recordId});

  final int recordId;

  static Future<void> open(BuildContext context, int id) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => DetailScreen(recordId: id)));

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  MedRecord? _record;
  bool _loaded = false;
  int _page = 0;
  final _pager = PageController(viewportFraction: 0.86);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final r = await RecordRepository.instance.find(widget.recordId);
    if (!mounted) return;
    setState(() {
      _record = r;
      _loaded = true;
      if (r != null && _page >= r.photos.length) _page = 0;
    });
  }

  Future<void> _edit() async {
    final r = _record;
    if (r == null) return;
    if (await EntryScreen.edit(context, r)) await _load();
  }

  Future<void> _delete() async {
    final r = _record;
    if (r == null) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirm(
      context,
      title: l10n.deleteRecordTitle,
      message: l10n.deleteRecordBody,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!ok) return;
    try {
      await RecordRepository.instance.delete(r);
      await AppState.instance.notifyDataChanged();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.deleted)));
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = _record;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.detailTitle),
        actions: [
          if (r != null) TextButton(onPressed: _edit, child: Text(l10n.edit)),
        ],
      ),
      body: !_loaded
          ? const SizedBox.shrink()
          : r == null
          ? Center(child: Text(l10n.recordNotFound))
          : _body(context, l10n, r),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, MedRecord r) {
    final person = AppState.instance.persons
        .where((p) => p.id == r.personId)
        .firstOrNull;
    final files = [for (final n in r.photos) PhotoStore.fileSync(n)];
    final ocr = [
      for (final (i, text) in r.ocrPages.indexed)
        if (text.trim().isNotEmpty) ...[
          if (r.photos.length > 1) '— ${l10n.pageNumber(i + 1)} —',
          text,
        ],
    ].join('\n');
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 32),
      children: [
        if (files.isNotEmpty) ...[
          SizedBox(
            height: 340,
            child: PageView.builder(
              itemCount: files.length,
              controller: _pager,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Semantics(
                  button: true,
                  label: l10n.zoomPhoto(i + 1),
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () =>
                        PhotoViewer.open(context, files, initialIndex: i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.group),
                      child: ColoredBox(
                        color: AppColors.track,
                        child: Image.file(
                          files[i],
                          fit: BoxFit.cover,
                          cacheWidth: 1000,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Text(
              files.length > 1
                  ? '${l10n.pageOf(_page + 1, files.length)}　${l10n.tapToZoom}'
                  : l10n.tapToZoom,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
        Group(
          children: [
            GroupRow(
              icon: Icons.event_rounded,
              title: l10n.fieldDate,
              subtitle: r.prescribedOn == null
                  ? l10n.dateNotSetShort
                  : formatDate(context, r.prescribedOn!),
            ),
            GroupRow(
              icon: Icons.local_hospital_outlined,
              title: l10n.fieldHospital,
              subtitle: r.hospital.isEmpty ? l10n.notEntered : r.hospital,
            ),
            GroupRow(
              icon: Icons.storefront_outlined,
              title: l10n.fieldPharmacy,
              subtitle: r.pharmacy.isEmpty ? l10n.notEntered : r.pharmacy,
            ),
            if (AppState.instance.persons.length > 1 && person != null)
              GroupRow(
                icon: Icons.person_rounded,
                title: l10n.fieldPerson,
                subtitle: person.name,
              ),
          ],
        ),
        Group(
          header: l10n.fieldMedicines,
          children: [
            if (r.medicines.isEmpty)
              GroupRow(title: l10n.noMedicineNames)
            else
              for (final m in r.medicines)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.medication_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SelectableText(
                          m,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
        if (r.memo.isNotEmpty)
          Group(
            header: l10n.fieldMemo,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: SizedBox(
                  width: double.infinity,
                  child: SelectableText(
                    r.memo,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        if (ocr.isNotEmpty)
          Group(
            header: l10n.fieldOcrText,
            footer: l10n.ocrTextNote,
            children: [
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 18),
                  childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  expandedAlignment: Alignment.topLeft,
                  title: Text(
                    l10n.showOcrText,
                    style: const TextStyle(fontSize: 18),
                  ),
                  children: [
                    SelectableText(
                      ocr,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            l10n.registeredAt(formatDate(context, r.createdAt)),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextButton.icon(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.deleteRecordTitle),
          ),
        ),
      ],
    );
  }
}
