import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventProvider(),
      child: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar App'),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return eventProvider.getEventsForDay(day);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1, // Coloca el punto debajo del número del día
                    child: Row(
                      children: events.map((event) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 7.0,
                          height: 7.0,
                          decoration: BoxDecoration(
                            color: event.color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: eventProvider
                  .getEventsForDay(_selectedDay ?? _focusedDay)
                  .length,
              itemBuilder: (context, index) {
                final event = eventProvider
                    .getEventsForDay(_selectedDay ?? _focusedDay)[index];
                return ListTile(
                  leading: Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: event.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(event.title),
                  subtitle: Text(
                    '${event.startTime.format(context)} - ${event.endTime.format(context)}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addEvent(context),
      ),
      
    );
  }

  void _addEvent(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final TextEditingController controller = TextEditingController();
    Color selectedColor = Colors.blue;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    String? selectedEquipment;

    final List<String> equipmentList = [
      'GPS SOUTH',
      'GPS HEMISPHERE',
      'GPS SANDING',
      'ESTACION TOTAL',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Event Title'),
                ),
                const SizedBox(height: 8.0),
                DropdownButton<Color>(
                  value: selectedColor,
                  items: [
                    DropdownMenuItem(
                      value: Colors.blue,
                      child: Text('Blue', style: TextStyle(color: Colors.blue)),
                    ),
                    DropdownMenuItem(
                      value: Colors.red,
                      child: Text('Red', style: TextStyle(color: Colors.red)),
                    ),
                    DropdownMenuItem(
                      value: Colors.green,
                      child:
                          Text('Green', style: TextStyle(color: Colors.green)),
                    ),
                  ],
                  onChanged: (Color? value) {
                    if (value != null) {
                      setState(() {
                        selectedColor = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8.0),
                TextButton(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        startTime = selectedTime;
                      });
                    }
                  },
                  child: Text(startTime == null
                      ? 'Select Start Time'
                      : 'Start Time: ${startTime!.format(context)}'),
                ),
                TextButton(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        endTime = selectedTime;
                      });
                    }
                  },
                  child: Text(endTime == null
                      ? 'Select End Time'
                      : 'End Time: ${endTime!.format(context)}'),
                ),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Select Equipment'),
                  value: selectedEquipment,
                  items: equipmentList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedEquipment = newValue;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  if (controller.text.isEmpty ||
                      startTime == null ||
                      endTime == null ||
                      selectedEquipment == null) return;
                  eventProvider.addEvent(
                    _selectedDay ?? _focusedDay,
                    Event(
                      title: controller.text,
                      color: selectedColor,
                      startTime: startTime!,
                      endTime: endTime!,
                      equipment:
                          selectedEquipment!, // Asegúrate de manejar esto en tu clase Event
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
