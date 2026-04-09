class CalendarLogic {
  static const weekdays = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"];
  static const months = [
    "Januar",
    "Februar",
    "März",
    "April",
    "Mai",
    "Juni",
    "Juli",
    "August",
    "September",
    "Oktober",
    "November",
    "Dezember",
  ];

  static List<String> get weekdaysHeader => [
    "Mo",
    "Di",
    "Mi",
    "Do",
    "Fr",
    "Sa",
    "So",
  ];
  static bool isHoliday(DateTime d) {
    final y = d.year;
    final e = _easter(y);
    final f = [
      DateTime(y, 1, 1),
      DateTime(y, 5, 1),
      DateTime(y, 10, 3),
      DateTime(y, 12, 25),
      DateTime(y, 12, 26),
    ];
    final v = [
      e.subtract(const Duration(days: 2)),
      e.add(const Duration(days: 1)),
      e.add(const Duration(days: 39)),
      e.add(const Duration(days: 50)),
    ];
    return [...f, ...v].any((h) => h.day == d.day && h.month == d.month);
  }

  static DateTime _easter(int y) {
    int a = y % 19,
        b = y ~/ 100,
        c = y % 100,
        d = b ~/ 4,
        e = b % 4,
        g = (8 * b + 13) ~/ 25,
        h = (19 * a + b - d - g + 15) % 30,
        i = c ~/ 4,
        k = c % 4,
        l = (32 + 2 * e + 2 * i - h - k) % 7,
        m = (a + 11 * h + 22 * l) ~/ 451;
    return DateTime(
      y,
      (h + l - 7 * m + 114) ~/ 31,
      ((h + l - 7 * m + 114) % 31) + 1,
    );
  }
}
