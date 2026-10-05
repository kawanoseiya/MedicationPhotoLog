import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// スライドする切り替えボタン（iOS のセグメントに近い形）。
///
/// 選択中の項目は白い面で示し、文字の太さも変えて色だけに頼らない。
class PillSegmented<T> extends StatelessWidget {
  const PillSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final index = values.indexOf(selected);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.track,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / values.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: width * index,
                top: 0,
                bottom: 0,
                width: width,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final v in values)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: v == selected,
                        label: label(v),
                        excludeSemantics: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          onTap: () => onChanged(v),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 44),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    label(v),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: v == selected
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: v == selected
                                          ? AppColors.text
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// iOS の設定アプリのような、角の丸いまとまり。行の間は細い線で区切る。
class Group extends StatelessWidget {
  const Group({super.key, this.header, this.footer, required this.children});

  final String? header;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Semantics(
                header: true,
                child: Text(
                  header!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.group),
            child: ColoredBox(
              color: AppColors.subtle,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const Divider(indent: 18, endIndent: 0),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
              child: Text(
                footer!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// [Group] の中の1行。
class GroupRow extends StatelessWidget {
  const GroupRow({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.selected,
  });

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;

  /// 右側に出す現在値。
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  /// 選択肢の行として使う場合のチェック状態。
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final titleColor = destructive ? AppColors.danger : AppColors.text;
    final Widget? end =
        trailing ??
        (selected != null
            ? (selected!
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 28,
                    )
                  : const SizedBox(width: 28))
            : (onTap != null && !destructive
                  ? const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 28,
                    )
                  : null));
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 26,
                    color: destructive
                        ? AppColors.danger
                        : (iconColor ?? AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          color: titleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                if (value != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      value!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ?end,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum NoticeTone { info, caution }

/// 画面上部の短い案内。
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.text,
    required this.icon,
    this.tone = NoticeTone.info,
  });

  final String text;
  final IconData icon;
  final NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      NoticeTone.info => (AppColors.primarySoft, AppColors.primary),
      NoticeTone.caution => (AppColors.cautionSoft, AppColors.caution),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.inner),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, color: fg, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                height: 1.45,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 下部のタブ。選択中は色と太さの両方で示す。
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final List<(IconData, IconData, String)> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == index,
                  label: items[i].$3,
                  excludeSemantics: true,
                  child: InkResponse(
                    onTap: () => onChanged(i),
                    highlightShape: BoxShape.rectangle,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            i == index ? items[i].$2 : items[i].$1,
                            size: 28,
                            color: i == index
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[i].$3,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: i == index
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: i == index
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// iOS 標準の見た目の確認ダイアログ。確定で true を返す。
/// 選択肢を縦に並べた確認ダイアログ。最初の選択肢を既定（太字）にする。
/// キャンセルしたら null。
Future<T?> showChoices<T>(
  BuildContext context, {
  required String title,
  required String message,
  required List<(T, String)> choices,
  required String cancelLabel,
}) => showCupertinoDialog<T>(
  context: context,
  builder: (context) => CupertinoAlertDialog(
    title: Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
    ),
    content: Text(message, style: const TextStyle(fontSize: 16, height: 1.45)),
    actions: [
      for (final (i, (value, label)) in choices.indexed)
        CupertinoDialogAction(
          isDefaultAction: i == 0,
          onPressed: () => Navigator.pop(context, value),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      CupertinoDialogAction(
        onPressed: () => Navigator.pop(context),
        child: Text(cancelLabel, style: const TextStyle(fontSize: 18)),
      ),
    ],
  ),
);

Future<bool> showConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16, height: 1.45),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel, style: const TextStyle(fontSize: 18)),
        ),
        CupertinoDialogAction(
          isDefaultAction: !destructive,
          isDestructiveAction: destructive,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel, style: const TextStyle(fontSize: 18)),
        ),
      ],
    ),
  );
  return result == true;
}
