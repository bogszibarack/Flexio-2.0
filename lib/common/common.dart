import 'package:intl/intl.dart';

String getTime(int value, {String formatStr = "hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.format(
      DateTime.fromMillisecondsSinceEpoch(value * 60 * 1000, isUtc: true));
}

String getStringDateToOtherFormate(String dateStr,
    {String inputFormatStr = "dd/MM/yyyy hh:mm aa",
    String outFormatStr = "hh:mm a"}) {
  var format = DateFormat(outFormatStr);
  return format.format(stringToDate(dateStr, formatStr: inputFormatStr));
}

DateTime stringToDate(String dateStr, {String formatStr = "hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.parse(dateStr);
}

DateTime dateToStartDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String dateToString(DateTime date, {String formatStr = "yyyy. MM. dd. HH:mm"}) {
  return _formatDate(date, formatStr);
}

String _formatDate(DateTime date, String formatStr) {
  try {
    return DateFormat(formatStr).format(date);
  } on Object {
    return dateToNumeric(date);
  }
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

String getDayTitle(String dateStr, {String formatStr = "dd/MM/yyyy hh:mm a"}) {
  return dateToDayTitle(stringToDate(dateStr, formatStr: formatStr));
}