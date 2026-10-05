import 'package:flutter/material.dart';

import '../data/record_repository.dart';
import '../l10n/app_localizations.dart';
import '../models/med_record.dart';
import '../services/app_state.dart';
import '../widgets/ui.dart';

/// 家族（記録を分ける人）の追加・名前の変更・削除。
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  static Future<String?> _askName(
    BuildContext context, {
    required String title,
    String initial = '',
  }) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          style: const TextStyle(fontSize: 19),
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: l10n.personNameHint),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    ).then((v) {
      final name = v?.trim() ?? '';
      return name.isEmpty ? null : name;
    });
  }

  Future<void> _add(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final name = await _askName(context, title: l10n.addPerson);
    if (name == null) return;
    final person = await AppState.instance.addPerson(name);
    await AppState.instance.selectPerson(person.id!);
  }

  Future<void> _edit(BuildContext context, Person person) async {
    final l10n = AppLocalizations.of(context);
    final action = await showChoices<String>(
      context,
      title: person.name,
      message: '',
      choices: [
        ('rename', l10n.renamePerson),
        if (AppState.instance.persons.length > 1) ('delete', l10n.deletePerson),
      ],
      cancelLabel: l10n.cancel,
    );
    if (!context.mounted) return;
    if (action == 'rename') {
      final name = await _askName(
        context,
        title: l10n.renamePerson,
        initial: person.name,
      );
      if (name != null) await AppState.instance.renamePerson(person.id!, name);
    } else if (action == 'delete') {
      final count = await RecordRepository.instance.countFor(person.id!);
      if (!context.mounted) return;
      final ok = await showConfirm(
        context,
        title: l10n.deletePersonTitle(person.name),
        message: l10n.deletePersonBody(count),
        confirmLabel: l10n.delete,
        cancelLabel: l10n.cancel,
        destructive: true,
      );
      if (ok) await AppState.instance.deletePerson(person.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageFamily)),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final state = AppState.instance;
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [
              Group(
                footer: l10n.familyEditNote,
                children: [
                  for (final p in state.persons)
                    GroupRow(
                      icon: Icons.person_rounded,
                      title: p.name,
                      subtitle: p.id == state.currentPersonId
                          ? l10n.currentlyShown
                          : null,
                      onTap: () => _edit(context, p),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () => _add(context),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: Text(l10n.addPerson),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
