import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

/// 「2026年10月5日(月)」の形。
String formatDate(BuildContext context, DateTime date, {bool withYear = true}) {
  final locale = _locale(context);
  return (withYear ? DateFormat.yMMMEd(locale) : DateFormat.MMMEd(locale))
      .format(date);
}

/// 「2026年10月」の形（履歴の見出し）。
String formatMonth(BuildContext context, DateTime date) =>
    DateFormat.yMMMM(_locale(context)).format(date);

/// 一覧用の短い日付。今年なら年を省く。
String formatListDate(BuildContext context, DateTime date) =>
    formatDate(context, date, withYear: date.year != DateTime.now().year);
