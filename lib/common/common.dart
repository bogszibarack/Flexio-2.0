import 'package:intl/intl.dart';

String getTime(int value, {String formatStr = "hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.format(
      DateTime.fromMillisecondsSinceEpoch(value * 60 * 1000, isUtc: true));
}

DateTime dateToStartDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

const List<String> _huMonths = [
  "január",
  "február",
  "március",
  "április",
  "május",
  "június",
  "július",
  "augusztus",
  "szeptember",
  "október",
  "november",
  "december",
];

const List<String> _huWeekdays = [
  "hétfő",
  "kedd",
  "szerda",
  "csütörtök",
  "péntek",
  "szombat",
  "vasárnap",
];

const List<String> _huMonthsShort = [
  "jan.",
  "febr.",
  "márc.",
  "ápr.",
  "máj.",
  "jún.",
  "júl.",
  "aug.",
  "szept.",
  "okt.",
  "nov.",
  "dec.",
];

String dateToMonthDay(DateTime date) =>
    "${_huMonths[date.month - 1]} ${date.day}.";

String dateToShortMonthDay(DateTime date) =>
    "${_huMonthsShort[date.month - 1]} ${date.day}.";

String dateToYearMonth(DateTime date) =>
    "${date.year}. ${_huMonths[date.month - 1]}";

String dateToYearMonthDay(DateTime date) =>
    "${date.year}. ${_huMonths[date.month - 1]} ${date.day}.";

String dateToNumeric(DateTime date) =>
    "${date.year}. ${date.month.toString().padLeft(2, "0")}. ${date.day.toString().padLeft(2, "0")}.";

String dateToWeekday(DateTime date) => _huWeekdays[date.weekday - 1];

String dateToDayTitle(DateTime date) {
  var diff =
      dateToStartDate(date).difference(dateToStartDate(DateTime.now())).inDays;

  if (diff == 0) {
    return "Ma";
  } else if (diff == 1) {
    return "Holnap";
  } else if (diff == -1) {
    return "Tegnap";
  }

  return "${_huMonths[date.month - 1]} ${date.day}., ${_huWeekdays[date.weekday - 1]}";
}

String dateToTimeLabel(DateTime date) {
  return DateFormat("HH:mm").format(date);
}
