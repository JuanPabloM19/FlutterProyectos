import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import 'package:intl/intl.dart'; // Para la personalización de la fecha

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
        automaticallyImplyLeading: false,
        title: Center(child: const Text('Página Inicio')),
        backgroundColor: Color(0xFF010618), // Fondo del AppBar
        foregroundColor: Colors.white, // Cambiado a blanco
      ),
      body: Container(
        color: const Color(0xFF010618), // Fondo oscuro
        child: Column(
          children: [
            TableCalendar<Event>(
              locale: 'es_ES',
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
                dowBuilder: (context, day) {
                  final text = DateFormat.E('es_ES').format(day).toUpperCase();
                  return Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Cambiado a blanco
                      ),
                    ),
                  );
                },
                headerTitleBuilder: (context, day) {
                  final text =
                      DateFormat.yMMMM('es_ES').format(day).toUpperCase();
                  return Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Cambiado a blanco
                      ),
                    ),
                  );
                },
                markerBuilder: (context, day, events) {
                  final eventCount = events.length;
                  if (eventCount > 0) {
                    List<Widget> markers = [];
                    for (int i = 0; i < eventCount && i < 3; i++) {
                      markers.add(
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          width: 6.0,
                          height: 6.0,
                          decoration: BoxDecoration(
                            color: events[i].color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    if (eventCount > 3) {
                      markers.add(
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: Text(
                            '+${eventCount - 3}',
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.white), // Cambiado a blanco
                          ),
                        ),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: markers,
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left,
                    color: Colors.white), // Flecha izquierda blanca
                rightChevronIcon: Icon(Icons.chevron_right,
                    color: Colors.white), // Flecha derecha blanca
              ),
              calendarStyle: const CalendarStyle(
                defaultTextStyle:
                    TextStyle(color: Colors.white), // Cambiado a blanco
                weekendTextStyle:
                    TextStyle(color: Colors.white), // Cambiado a blanco
                todayTextStyle:
                    TextStyle(color: Colors.white), // Cambiado a blanco
                selectedTextStyle: TextStyle(
                    color:
                        Colors.black), // Texto del día seleccionado (opcional)
                // Puedes agregar más estilos si lo deseas
              ),
            ),
            const SizedBox(height: 8.0),
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
                    title: Text(
                      event.title,
                      style: const TextStyle(
                          color: Colors.white), // Cambiado a blanco
                    ),
                    subtitle: Text(
                      '${event.startTime.format(context)} - ${event.endTime.format(context)}',
                      style: const TextStyle(
                          color: Colors.white), // Cambiado a blanco
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Opacity(
        opacity: 0.8, // Establece la opacidad al 60%
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF80B3FF), // Color de fondo del botón
          child: const Icon(
            Icons.add,
            color: Color(0xFF010618), // Color del icono
          ),
          onPressed: () => _addEvent(context),
        ),
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
      'ESTACIÓN TOTAL',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Agregar Evento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Título Evento'),
                ),
                const SizedBox(height: 8.0),
                DropdownButton<Color>(
                  value: selectedColor,
                  items: [
                    DropdownMenuItem(
                      value: Colors.blue,
                      child: Text('Azul', style: TextStyle(color: Colors.blue)),
                    ),
                    DropdownMenuItem(
                      value: Colors.red,
                      child: Text('Rojo', style: TextStyle(color: Colors.red)),
                    ),
                    DropdownMenuItem(
                      value: Colors.green,
                      child:
                          Text('Verde', style: TextStyle(color: Colors.green)),
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
                      ? 'Seleccionar hora inicial'
                      : 'Hora de inicio: ${startTime!.format(context)}'),
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
                      ? 'Seleccionar hora de finalización'
                      : 'Fin del tiempo: ${endTime!.format(context)}'),
                ),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Seleccionar equipo'),
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
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Agregar'),
                onPressed: () {
                  if (controller.text.isEmpty ||
                      startTime == null ||
                      endTime == null ||
                      selectedEquipment == null) return;
                  eventProvider.addEvent(
                    _selectedDay ?? _focusedDay,
                    Event(
                      title: controller.text,
                      date: _selectedDay ?? _focusedDay,
                      color: selectedColor,
                      startTime: startTime!,
                      endTime: endTime!,
                      equipment: selectedEquipment!,
                    ),
                  );
                  Navigator.pop(context);
                  controller.clear();
                  setState(() {
                    startTime = null;
                    endTime = null;
                    selectedEquipment = null;
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
