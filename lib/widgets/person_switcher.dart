import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/family_screen.dart';
import '../services/app_state.dart';
import '../theme.dart';

/// 画面上部の「誰の記録か」の切り替え。押すと家族の一覧が出る。
class PersonSwitcher extends StatelessWidget {
  const PersonSwitcher({super.key});

  Future<void> _open(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final state = AppState.instance;
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  l10n.whoseRecords,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final p in state.persons)
                ListTile(
                  minTileHeight: 60,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.person_rounded, size: 28),
                  title: Text(p.name, style: const TextStyle(fontSize: 19)),
                  trailing: p.id == state.currentPersonId
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 28,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, p.id),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, -1),
                  icon: const Icon(Icons.group_rounded),
                  label: Text(l10n.manageFamily),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    if (picked == -1) {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const FamilyScreen()));
    } else {
      await state.selectPerson(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final name = AppState.instance.currentPerson.name;
        return Semantics(
          button: true,
          label: l10n.switchPersonLabel(name),
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: () => _open(context),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.fromLTRB(12, 6, 10, 6),
              decoration: BoxDecoration(
                color: AppColors.subtle,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
