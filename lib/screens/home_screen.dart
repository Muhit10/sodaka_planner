import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'day_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: const [
                  Color(0xFFF66A4B),
                  Color(0xFFA24AE7),
                  Color(0xFF4859F3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
          child: const Text(
            'Sadaka Planner',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.dashboard_outlined,
              color: Color(0xFFF66A4B),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const CalendarWidget(),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime selectedDate;
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    // Always use current date and time when app starts
    final now = DateTime.now();
    selectedDate = now;
    selectedMonth = now.month;
    selectedYear = now.year;
  }

  // Get month name from month number
  String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(selectedYear, month));
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date
    final now = DateTime.now();

    // Create a list of days for the selected month
    final List<DateTime> monthCalendar = [];

    // Get the first day of selected month
    final firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);

    // Get the number of days in selected month
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;

    // Fill the calendar with all days of selected month
    for (int i = 1; i <= daysInMonth; i++) {
      monthCalendar.add(DateTime(selectedYear, selectedMonth, i));
    }

    // Calculate the number of rows needed for the calendar
    final int firstWeekday =
        firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday
    final int totalCells = firstWeekday + daysInMonth;
    final int totalRows = (totalCells / 7).ceil();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${getMonthName(selectedMonth)} $selectedYear',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA24AE7),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: () {
                  _showMonthPicker(context);
                },
              ),
            ],
          ),
        ),
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            CalendarHeader('Sun'),
            CalendarHeader('Mon'),
            CalendarHeader('Tue'),
            CalendarHeader('Wed'),
            CalendarHeader('Thu'),
            CalendarHeader('Fri'), // Friday with special color
            CalendarHeader('Sat'),
          ],
        ),
        const SizedBox(height: 8),
        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: totalRows * 7,
            itemBuilder: (context, index) {
              // Calculate the day to display
              final int displayIndex = index - firstWeekday;

              // If the index is before the first day of the month or after the last day
              if (displayIndex < 0 || displayIndex >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = displayIndex + 1;
              final date = DateTime(selectedYear, selectedMonth, day);
              final isToday =
                  date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final isPastOrToday =
                  date.isBefore(now) ||
                  (date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day);

              return CalendarDay(
                day: day,
                isToday: isToday,
                isClickable: isPastOrToday,
                date: date,
              );
            },
          ),
        ),
      ],
    );
  }

  // Show month picker dialog
  void _showMonthPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthNumber = index + 1;
                return ListTile(
                  title: Text(getMonthName(monthNumber)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      selectedMonth = monthNumber;
                      selectedDate = DateTime(selectedYear, selectedMonth, 1);
                    });

                    // We don't save selected month and year anymore
                    // We always want to show current month when app restarts
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class CalendarHeader extends StatelessWidget {
  final String text;

  const CalendarHeader(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Special case for Friday
    final bool isFriday = text == 'Fri';
    final Color textColor = isFriday ? const Color(0xFFF66A4B) : Colors.black;

    return Container(
      width: 40,
      color:
          isFriday
              ? const Color(0xFFF66A4B).withOpacity(0.1)
              : const Color(0xFF4859F3).withOpacity(0.1),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}

class CalendarDay extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isClickable;
  final DateTime date;

  const CalendarDay({
    Key? key,
    required this.day,
    required this.isToday,
    required this.isClickable,
    required this.date,
  }) : super(key: key);

  // Check if the date is a Friday (weekday 5)
  bool get isFriday => date.weekday == 5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          isClickable
              ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayScreen(date: date),
                  ),
                );
              }
              : null,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        color:
            isToday
                ? Colors.blue.withOpacity(0.8)
                : isFriday
                ? const Color(0xFFF66A4B).withOpacity(0.001)
                : Colors.white.withOpacity(0.8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isToday
                        ? Colors.blue.withOpacity(0.2)
                        : isFriday
                        ? const Color(0xFFF66A4B).withOpacity(0.001)
                        : Colors.white.withOpacity(0.2),
                    isToday
                        ? Colors.blue.withOpacity(0.1)
                        : isFriday
                        ? const Color(0xFFF66A4B).withOpacity(0.001)
                        : Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color:
                      isClickable
                          ? isFriday
                              ? const Color(0xFFF66A4B).withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isToday
                            ? Colors.white
                            : isClickable
                            ? isFriday
                                ? const Color(0xFFF66A4B)
                                : Colors.black
                            : Colors.grey,
                    fontWeight:
                        isToday || isFriday ? FontWeight.bold : FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
