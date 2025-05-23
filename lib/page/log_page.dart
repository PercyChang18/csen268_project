import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Dates'), centerTitle: true),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1), // set to be this year
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            headerStyle: HeaderStyle(
              // disable the changing format button
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(fontSize: 21),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white),
              weekendStyle: TextStyle(color: Color(0xFF6A6A6A)),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
              // TODO: use the database to show the workout for that day
              // _showWorkoutsForDate(selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          // Display workouts for the selected date here
          Expanded(
            child:
                _selectedDay != null
                    ? Center(
                      child: Text(
                        'Workouts for: ${_selectedDay!.toLocal().toIso8601String().split('T')[0]}',
                      ),
                    )
                    : const Center(
                      child: Text('Select a date to see workouts.'),
                    ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutsForDate(DateTime date) {
    // TODO: fetch data from the database
  }
}
