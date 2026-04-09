import 'package:flutter/material.dart';
import 'package:flutter_calendar/controllers/themeController/theme_controller.dart';
import 'dart:convert';
import 'package:flutter_calendar/shared/consts/classes/calendar_logic.dart';
import 'package:flutter_calendar/shared/consts/classes/theme_manager.dart';
import 'package:flutter_calendar/shared/consts/enums/app_theme.dart';
import 'package:flutter_calendar/widgets/theme_picker.dart/themepicker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class KalenderBlatt extends StatefulWidget {
  final ThemeController themeController;
  const KalenderBlatt({super.key, required this.themeController});

  @override
  State<KalenderBlatt> createState() => _KalenderBlattState();
}

class _KalenderBlattState extends State<KalenderBlatt> {
  DateTime _viewDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _events = [];
  bool _isLoading = false;

  String? _activeRequestTag;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final requestTag = DateTime.now().millisecondsSinceEpoch.toString();
    _activeRequestTag = requestTag;

    setState(() => _isLoading = true);

    final m = _selectedDate.month.toString().padLeft(2, '0');
    final d = _selectedDate.day.toString().padLeft(2, '0');

    try {
      final response = await http.get(
        Uri.parse(
          'https://de.wikipedia.org/api/rest_v1/feed/onthisday/events/$m/$d',
        ),
      );

      if (_activeRequestTag != requestTag) return;

      if (response.statusCode == 200) {
        setState(() {
          _events = json.decode(response.body)['events'].take(5).toList();
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      if (_activeRequestTag == requestTag) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showThemePicker() {
    showThemePickerBottomSheet(context, widget.themeController);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 850;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kalenderblatt",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _showThemePicker,
            icon: const Icon(Icons.palette_rounded),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainer,
              elevation: 1,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        key: const PageStorageKey('main_scroll'),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      width: isWide ? 400 : double.infinity,
                      child: _buildInfoCard(),
                    ),
                    SizedBox(
                      width: isWide ? 500 : double.infinity,
                      child: _buildCalendar(),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Divider(),
                ),
                _buildEventsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final dayOfYear = int.parse(DateFormat("D").format(_selectedDate));
    final daysLeft = DateTime(
      _selectedDate.year,
      12,
      31,
    ).difference(_selectedDate).inDays;
    final holiday = CalendarLogic.isHoliday(_selectedDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_selectedDate.day}. ${CalendarLogic.months[_selectedDate.month - 1]}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Es handelt sich um den $dayOfYear. Tag des Jahres. Bis zum Jahresende sind es noch $daysLeft Tage.",
              style: const TextStyle(height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                holiday
                    ? "🎉 Feiertag in Deutschland"
                    : "Kein bundesweiter Feiertag",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _viewDate.year,
      _viewDate.month,
    );
    final firstDayOffset =
        DateTime(_viewDate.year, _viewDate.month, 1).weekday - 1;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => setState(
                    () => _viewDate = DateTime(
                      _viewDate.year,
                      _viewDate.month - 1,
                    ),
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  "${CalendarLogic.months[_viewDate.month - 1]} ${_viewDate.year}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(
                    () => _viewDate = DateTime(
                      _viewDate.year,
                      _viewDate.month + 1,
                    ),
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: CalendarLogic.weekdaysHeader
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.7,
                            ),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: daysInMonth + firstDayOffset,
              itemBuilder: (context, i) {
                if (i < firstDayOffset) return const SizedBox();
                final d = i - firstDayOffset + 1;
                final date = DateTime(_viewDate.year, _viewDate.month, d);
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                final isToday = DateUtils.isSameDay(date, DateTime.now());

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
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 1,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        "$d",
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
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

  Widget _buildEventsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Historische Ereignisse",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ..._events.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e['text'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
