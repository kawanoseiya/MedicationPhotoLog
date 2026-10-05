import 'package:flutter/material.dart';

import '../data/photo_store.dart';
import '../l10n/app_localizations.dart';
import '../models/med_record.dart';
import '../theme.dart';
import '../util/format.dart';

/// 履歴の1件。日付・薬名・医療機関／薬局と、1枚目の写真の縮小版。
class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record, required this.onTap});

  final MedRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = record;
    final date = r.prescribedOn != null
        ? formatListDate(context, r.prescribedOn!)
        : l10n.noDateAdded(formatListDate(context, r.createdAt));
    final medicines = r.medicines.isEmpty
        ? l10n.noMedicineNames
        : r.medicines.join(l10n.listSeparator);
    final places = [
      r.hospital,
      r.pharmacy,
    ].where((s) => s.isNotEmpty).join(' · ');
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(name: r.photos.firstOrNull),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: r.prescribedOn != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      medicines,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: r.medicines.isEmpty
                            ? AppColors.textSecondary
                            : AppColors.text,
                      ),
                    ),
                    if (places.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          places,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: name == null
            ? const ColoredBox(
                color: AppColors.track,
                child: Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.textSecondary,
                  size: 30,
                ),
              )
            : Image.file(
                PhotoStore.fileSync(name!),
                fit: BoxFit.cover,
                // 書類は上端に見出しがあるので、上から見せる。
                alignment: Alignment.topCenter,
                cacheWidth: 192,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: AppColors.track,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }
}
