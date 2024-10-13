import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/equipment_model.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/pages/listAdmin_page.dart';
import 'package:flutter_app_final/providers/equipment_provider.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';
import 'package:flutter_app_final/utils/equipmentWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.isAdmin;
    return ChangeNotifierProvider(
      create: (_) => EventProvider(),
      child: isAdmin ? RentalListPage() : const CalendarPage(),
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
  bool isAdmin = false;
  String? _userId;
  String? userName;
  DateTime _selectedDate =
      DateTime.now(); // Variable para almacenar la fecha seleccionada

  // Variable para guardar los eventos del día seleccionado
  List<Event> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadAdminStatus();
    _loadUserId();
    _loadUserName();
    Provider.of<EventProvider>(context, listen: false).loadEvents();

    // Inicializa _selectedDay con hoy
  }

  Future<void> _loadAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getString('email') == 'joariera@gmail.com';
    });
  }

  // Método para cargar el nombre de usuario
  Future<void> _loadUserName() async {
    if (_userId != null) {
      String? name = await DatabaseHelper().getUserName(int.parse(_userId!));
      setState(() {
        userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: const Text('Calendario')),
        backgroundColor: const Color(0xFF010618),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFF010618),
        child: Column(children: [
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
                _selectedDate = selectedDay;
                _loadSelectedEvents();
              });
            },
            eventLoader: (day) {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);

              if (userProvider.isAdmin) {
                return eventProvider.getAllEventsForDay(
                    day); // Para el admin, obtener todos los eventos
              } else {
                return eventProvider.getEventsForDay(
                    day, _userId ?? ""); // Usar el _userId cargado en el estado
              }
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
                      color: Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                );
              },
              markerBuilder: (context, day, events) {
                final eventCount = events.length;
                if (eventCount > 0) {
                  List<Widget> markers = [];
                  for (int i = 0; i < eventCount && i < 3; i++) {
                    Color markerColor = events[i].color;

                    // Aplicar un color específico para el admin
                    if (isAdmin) {
                      markerColor = events[i].color.withOpacity(0.8);
                    }

                    markers.add(
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        width: 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color: markerColor,
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
                              fontSize: 12.0, color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: markers,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white),
              todayTextStyle: const TextStyle(color: Colors.white),
              selectedTextStyle: const TextStyle(color: Colors.black),
              todayDecoration: BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
              // Cambiar el color de los días alquilados para el admin
              defaultDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              withinRangeDecoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                shape: BoxShape.circle,
              ),
              outsideDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              holidayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: FutureBuilder<List<Event>>(
              future: _getEventsForSelectedDay(
                  eventProvider), // Pasar el eventProvider
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay eventos para hoy.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final events = snapshot.data!;
                _selectedEvents = events; // Guardar eventos seleccionados

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
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
                        event.equipment,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${event.startTime.format(context)} - ${event.endTime.format(context)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              _editEvent(context, event);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteEvent(event);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón para agregar eventos
          FloatingActionButton(
            onPressed: () => _addEvent(context), // Lógica para agregar evento
            backgroundColor: const Color(0xFF80B3FF),
            child: const Icon(
              Icons.add,
              color: Color(0xFF010618),
            ),
          ),
          const SizedBox(height: 16),
          // Botón para regresar al listado de alquileres, visible solo para admin
          if (isAdmin)
            FloatingActionButton(
              onPressed: () {
                Navigator.pop(context); // Regresar al listado de alquileres
              },
              backgroundColor: const Color(0xFF80B3FF),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF010618),
              ),
            ),
        ],
      ),
    );
  }

  // Cargar eventos para el día seleccionado
  void _loadSelectedEvents() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final events = await _getEventsForSelectedDay(eventProvider);
    setState(() {
      _selectedEvents = events; // Actualiza la lista de eventos seleccionados
    });
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Obtener el ID del usuario logueado
  }

  Future<List<Event>> _getEventsForSelectedDay(
      EventProvider eventProvider) async {
    if (isAdmin) {
      // Si es administrador, obtener todos los eventos
      return eventProvider.getAllEventsForDay(_selectedDate);
    } else {
      final userId = await _getUserId();
      if (userId != null && _selectedDay != null) {
        return eventProvider.getEventsForDay(_selectedDay!, userId);
      }
      return [];
    } // Devuelve una lista vacía si el usuario no está logueado o no hay día seleccionado
  }

  void _editEvent(BuildContext context, Event event) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final equipmentProvider =
        Provider.of<EquipmentProvider>(context, listen: false);

    Color selectedColor = event.color;
    TimeOfDay startTime = event.startTime;
    TimeOfDay endTime = event.endTime;

    await equipmentProvider.fetchEquipments();
    List<Equipment> equipmentList = equipmentProvider.equipmentList;

    Equipment selectedEquipment = equipmentList.firstWhere(
      (e) => e.nameE == event.equipment,
      orElse: () {
        throw Exception('Equipo no encontrado');
      },
    );

    String eventType = event.title;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Evento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: eventType,
                items: const [
                  DropdownMenuItem(value: 'Préstamo', child: Text('Préstamo')),
                  DropdownMenuItem(value: 'Alquiler', child: Text('Alquiler')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    eventType = newValue;
                  }
                },
              ),
              EquipmentWidget(
                selectedEquipment: selectedEquipment,
                equipmentList: equipmentList,
                onChanged: (equipment) {
                  selectedEquipment = equipment!;
                },
                selectedDate: event.date,
                startTime: startTime,
                endTime: endTime,
                userId: event.userId,
              ),
              ListTile(
                title: const Text('Hora de Inicio'),
                trailing: Text(startTime.format(context)),
                onTap: () async {
                  final TimeOfDay? newTime = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (newTime != null) {
                    startTime = newTime;
                  }
                },
              ),
              ListTile(
                title: const Text('Hora de Fin'),
                trailing: Text(endTime.format(context)),
                onTap: () async {
                  final TimeOfDay? newTime = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (newTime != null) {
                    endTime = newTime;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          // Botón Cancelar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF80B3FF),
              foregroundColor: Color(0xFF010618),
            ),
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          // Botón Actualizar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 1, 170, 15),
              foregroundColor: Colors.white,
              textStyle:
                  const TextStyle(fontWeight: FontWeight.bold), // Negrita
            ),
            child: const Text('Actualizar'),
            onPressed: () {
              if (selectedEquipment == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor, selecciona un equipo.')),
                );
                return;
              }

              Event updatedEvent = event.copyWith(
                title: eventType,
                equipment: selectedEquipment.nameE,
                startTime: startTime,
                endTime: endTime,
              );

              eventProvider.editEvent(
                  context, event.date, event, event.date, updatedEvent);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

// Método para eliminar un evento
  void _deleteEvent(Event event) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Evento'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este evento?'),
          actions: <Widget>[
            // Botón Cancelar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF80B3FF),
                foregroundColor: Color(0xFF010618),
              ),
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // Botón Eliminar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 228, 25, 10),
                foregroundColor: Colors.white,
                textStyle:
                    const TextStyle(fontWeight: FontWeight.bold), // Negrita
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                eventProvider.deleteEvent(context, event.date, event);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evento eliminado')),
                );
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  void _addEvent(BuildContext context) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final equipmentProvider =
        Provider.of<EquipmentProvider>(context, listen: false);
    Color selectedColor = Colors.blue;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    Equipment? selectedEquipment;

    final userId = await _getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, inicia sesión para agregar un evento.'),
        ),
      );
      return;
    }

    await equipmentProvider.fetchEquipments();
    await eventProvider.fetchEvents();

    // Tipo de evento inicial
    String eventType = 'Préstamo'; // Valor inicial

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Agregar Evento',
                style: TextStyle(color: Colors.black87)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: eventType,
                    items: const [
                      DropdownMenuItem(
                          value: 'Préstamo', child: Text('Préstamo')),
                      DropdownMenuItem(
                          value: 'Alquiler', child: Text('Alquiler')),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          eventType = newValue; // Actualiza el tipo de evento
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: 200,
                    child: DropdownButton<Color>(
                      isExpanded: true,
                      value: selectedColor,
                      items: const [
                        DropdownMenuItem(
                          value: Colors.blue,
                          child: Text('Azul',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 14)),
                        ),
                        DropdownMenuItem(
                          value: Colors.red,
                          child: Text('Rojo',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14)),
                        ),
                        DropdownMenuItem(
                          value: Colors.green,
                          child: Text('Verde',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 14)),
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
                  ),
                  const SizedBox(height: 8.0),
                  TextButton(
                    onPressed: () async {
                      final selectedStartTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedStartTime != null) {
                        setState(() {
                          startTime = selectedStartTime;
                        });
                      }
                    },
                    child: Text(
                      startTime == null
                          ? 'Seleccionar Hora Inicio'
                          : 'Hora Inicio: ${startTime!.format(context)}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final selectedEndTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedEndTime != null) {
                        setState(() {
                          endTime = selectedEndTime;
                        });
                      }
                    },
                    child: Text(
                      endTime == null
                          ? 'Seleccionar Hora Fin'
                          : 'Hora Fin: ${endTime!.format(context)}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  EquipmentWidget(
                    selectedEquipment: selectedEquipment,
                    equipmentList: equipmentProvider.equipmentList,
                    onChanged: (Equipment? equipment) {
                      setState(() {
                        selectedEquipment = equipment;
                      });
                    },
                    selectedDate: _selectedDay ?? _focusedDay,
                    userId: userId,
                    startTime: startTime ?? TimeOfDay.now(),
                    endTime: endTime ?? TimeOfDay.now(),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF80B3FF),
                  foregroundColor: Color(0xFF010618),
                ),
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 1, 170, 15),
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                ),
                child: const Text(
                  'Agregar',
                ),
                onPressed: () {
                  if (startTime == null || endTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Por favor, selecciona la hora de inicio y fin.'),
                      ),
                    );
                    return;
                  }
                  if (selectedEquipment == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, selecciona un equipo.'),
                      ),
                    );
                    return;
                  }

                  final isAvailable = eventProvider.isTeamAvailable(
                    selectedEquipment!.nameE,
                    _selectedDay ?? _focusedDay,
                    startTime!,
                    endTime!,
                  );

                  if (!isAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'El equipo ya está reservado en esta fecha y hora.'),
                      ),
                    );
                  } else {
                    // Agregar el evento aquí
                    eventProvider.addEvent(
                      context,
                      Event(
                        title: eventType,
                        date: _selectedDay ?? _focusedDay,
                        startTime: startTime!,
                        endTime: endTime!,
                        color: selectedColor,
                        equipment: selectedEquipment!.nameE,
                        userId: userId,
                        data:
                            'Your additional data', // Cambia según sea necesario
                      ),
                    );

                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }
}
