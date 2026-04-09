import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

enum AppTheme {
  light,
  dark,
  pinkyCandy,
  greenJungle,
  deepBlue,
  lightSky,
  yellowDessert,
  redVolcano,
  neonCity,
  shinyHeaven,
}

class ThemeManager {
  static Map<AppTheme, Map<String, dynamic>> themeDetails = {
    AppTheme.light: {
      'name': 'Light',
      'color': Colors.grey[200],
      'icon': Icons.wb_sunny,
    },
    AppTheme.dark: {
      'name': 'Dark',
      'color': Colors.grey[900],
      'icon': Icons.nightlight_round,
    },
    AppTheme.pinkyCandy: {
      'name': 'Pinky Candy',
      'color': Colors.pink[300],
      'icon': Icons.icecream,
    },
    AppTheme.greenJungle: {
      'name': 'Green Jungle',
      'color': Colors.green[800],
      'icon': Icons.forest,
    },
    AppTheme.deepBlue: {
      'name': 'Deep Blue',
      'color': Colors.blue[900],
      'icon': Icons.water,
    },
    AppTheme.lightSky: {
      'name': 'Light Sky',
      'color': Colors.lightBlue[200],
      'icon': Icons.cloud,
    },
    AppTheme.yellowDessert: {
      'name': 'Yellow Desert',
      'color': Colors.orange[300],
      'icon': Icons.wb_twilight,
    },
    AppTheme.redVolcano: {
      'name': 'Red Volcano',
      'color': Colors.red[900],
      'icon': Icons.volcano,
    },
    AppTheme.neonCity: {
      'name': 'Neon City',
      'color': Colors.purple[900],
      'icon': Icons.location_city,
    },
    AppTheme.shinyHeaven: {
      'name': 'Shiny Heaven',
      'color': Colors.yellow[300],
      'icon': Icons.star,
    },
  };

  static ThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return _buildTheme(
          Brightness.light,
          const Color(0xFF1A2A6C),
          const Color(0xFFF0F2F5),
        );
      case AppTheme.dark:
        return _buildTheme(
          Brightness.dark,
          const Color(0xFF8AB4F8),
          const Color(0xFF121212),
        );
      case AppTheme.pinkyCandy:
        return _buildTheme(Brightness.light, Colors.pink, Colors.pink[50]!);
      case AppTheme.greenJungle:
        return _buildTheme(
          Brightness.dark,
          Colors.greenAccent,
          const Color(0xFF0A2E0A),
        );
      case AppTheme.deepBlue:
        return _buildTheme(
          Brightness.dark,
          Colors.lightBlueAccent,
          const Color(0xFF041024),
        );
      case AppTheme.lightSky:
        return _buildTheme(
          Brightness.light,
          Colors.blue,
          const Color(0xFFE0F2FE),
        );
      case AppTheme.yellowDessert:
        return _buildTheme(
          Brightness.light,
          Colors.deepOrange,
          const Color(0xFFFFF3E0),
        );
      case AppTheme.redVolcano:
        return _buildTheme(
          Brightness.dark,
          Colors.orangeAccent,
          const Color(0xFF2B0000),
        );
      case AppTheme.neonCity:
        return _buildTheme(
          Brightness.dark,
          Colors.purpleAccent,
          const Color(0xFF1A0033),
        );
      case AppTheme.shinyHeaven:
        return _buildTheme(
          Brightness.light,
          Colors.yellow,
          const Color(0xFFFFFDE7),
        );
    }
  }

  static ThemeData _buildTheme(
    Brightness brightness,
    Color seedColor,
    Color bgColor,
  ) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.primary, 
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      useMaterial3: true,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTheme _currentTheme = AppTheme.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString('app_theme');
    if (savedTheme != null) {
      setState(() {
        _currentTheme = AppTheme.values.firstWhere(
          (e) => e.toString() == savedTheme,
          orElse: () => AppTheme.light,
        );
      });
    }
  }

  Future<void> _setTheme(AppTheme newTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', newTheme.toString());
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalenderblatt',
      debugShowCheckedModeBanner: false,
      theme: ThemeManager.getThemeData(_currentTheme),
      home: KalenderBlatt(
        currentTheme: _currentTheme,
        onThemeChanged: _setTheme,
      ),
    );
  }
}

class KalenderBlatt extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(AppTheme) onThemeChanged;

  const KalenderBlatt({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<KalenderBlatt> createState() => _KalenderBlattState();
}

class _KalenderBlattState extends State<KalenderBlatt> {
  DateTime _viewDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _events = [];
  bool _isLoadingEvents = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoadingEvents = true);
    final String mm = _selectedDate.month.toString().padLeft(2, '0');
    final String dd = _selectedDate.day.toString().padLeft(2, '0');

    try {
      final response = await http.get(
        Uri.parse(
          'https://de.wikipedia.org/api/rest_v1/feed/onthisday/events/$mm/$dd',
        ),
      );
      if (response.statusCode == 200) {
        setState(
          () => _events = json.decode(response.body)['events'].take(5).toList(),
        );
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      setState(() => _isLoadingEvents = false);
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _viewDate = DateTime(_viewDate.year, _viewDate.month + offset, 1);
    });
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Design auswählen",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppTheme.values.map((theme) {
                  final themeData = ThemeManager.themeDetails[theme]!;
                  final isSelected = theme == widget.currentTheme;

                  return InkWell(
                    onTap: () {
                      widget.onThemeChanged(theme);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: themeData['color'],
                            child: Icon(
                              themeData['icon'],
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            themeData['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 850;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kalenderblatt",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: _showThemePicker,
              icon: const Icon(Icons.palette),
              tooltip: 'Design ändern',
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        key: const PageStorageKey('main_calendar_scroll'),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                Wrap(
                  spacing: 30,
                  runSpacing: 30,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    SizedBox(
                      width: isWide ? 400 : double.infinity,
                      child: _buildInfoCard(),
                    ),
                    SizedBox(
                      width: isWide ? 500 : double.infinity,
                      child: _buildCalendarView(),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Divider(),
                ),
                _buildHistorySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final theme = Theme.of(context);
    final int dayOfYear = int.parse(DateFormat("D").format(_selectedDate));
    final bool isLeapYear =
        (_selectedDate.year % 4 == 0 && _selectedDate.year % 100 != 0) ||
        (_selectedDate.year % 400 == 0);
    final int totalDays = isLeapYear ? 366 : 365;
    final int daysLeft = totalDays - dayOfYear;
    final bool isHoliday = CalendarLogic.isPublicHoliday(_selectedDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_selectedDate.day}. ${CalendarLogic.monthsDE[_selectedDate.month - 1]} ${_selectedDate.year}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              "Der gewählte Tag ist ein ${CalendarLogic.weekdaysDE[_selectedDate.weekday % 7]}, der ${_selectedDate.day}. ${CalendarLogic.monthsDE[_selectedDate.month - 1]}.",
              style: const TextStyle(height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Es handelt sich um den $dayOfYear. Tag des Jahres. Bis zum Jahresende sind es noch $daysLeft Tage.",
              style: const TextStyle(height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isHoliday
                    ? "🎉 Dieser Tag ist ein gesetzlicher Feiertag in Deutschland."
                    : "An diesem Tag ist kein bundesweiter gesetzlicher Feiertag.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    final theme = Theme.of(context);
    final int daysInMonth = DateUtils.getDaysInMonth(
      _viewDate.year,
      _viewDate.month,
    );
    final int firstWeekday = DateTime(
      _viewDate.year,
      _viewDate.month,
      1,
    ).weekday;
    final int leadingSpaces = firstWeekday - 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _btnControl("<", () => _changeMonth(-1)),
                Text(
                  "${CalendarLogic.monthsDE[_viewDate.month - 1]} ${_viewDate.year}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _btnControl(">", () => _changeMonth(1)),
              ],
            ),
            const SizedBox(height: 20),
            _buildWeekdayHeader(),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: daysInMonth + leadingSpaces,
              itemBuilder: (context, index) {
                if (index < leadingSpaces) return const SizedBox.shrink();
                final int day = index - leadingSpaces + 1;
                final DateTime date = DateTime(
                  _viewDate.year,
                  _viewDate.month,
                  day,
                );
                final bool isSelected = DateUtils.isSameDay(
                  date,
                  _selectedDate,
                );
                final bool isToday = DateUtils.isSameDay(date, DateTime.now());

                return InkWell(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _fetchEvents();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isToday
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Center(
                      child: Text(
                        "$day",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: (isSelected || isToday)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : isToday
                              ? theme.colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnControl(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return Row(
      children: days.map((d) {
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ereignisse am ${_selectedDate.day}. ${CalendarLogic.monthsDE[_selectedDate.month - 1]}",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        if (_isLoadingEvents)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final e = _events[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${e['year']}:",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e['text'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class CalendarLogic {
  static const List<String> weekdaysDE = [
    "Sonntag",
    "Montag",
    "Dienstag",
    "Mittwoch",
    "Donnerstag",
    "Freitag",
    "Samstag",
  ];

  static const List<String> monthsDE = [
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

  static DateTime getEasterSunday(int year) {
    int a = year % 19,
        b = year ~/ 100,
        c = year % 100,
        d = b ~/ 4,
        e = b % 4,
        f = (b + 8) ~/ 25,
        g = (b - f + 1) ~/ 3,
        h = (19 * a + b - d - g + 15) % 30,
        i = c ~/ 4,
        k = c % 4,
        l = (32 + 2 * e + 2 * i - h - k) % 7,
        m = (a + 11 * h + 22 * l) ~/ 451;
    int month = (h + l - 7 * m + 114) ~/ 31;
    int day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  static bool isPublicHoliday(DateTime date) {
    final int year = date.year;
    final DateTime easter = getEasterSunday(year);
    final List<DateTime> fixed = [
      DateTime(year, 1, 1),
      DateTime(year, 5, 1),
      DateTime(year, 10, 3),
      DateTime(year, 12, 25),
      DateTime(year, 12, 26),
    ];
    final List<DateTime> movable = [
      easter.subtract(const Duration(days: 2)),
      easter.add(const Duration(days: 1)),
      easter.add(const Duration(days: 39)),
      easter.add(const Duration(days: 50)),
    ];
    return [
      ...fixed,
      ...movable,
    ].any((h) => h.day == date.day && h.month == date.month);
  }
}
