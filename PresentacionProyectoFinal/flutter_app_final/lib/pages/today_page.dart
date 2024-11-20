import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/equipment_model.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/pages/listAdmin_page.dart';
import 'package:flutter_app_final/providers/equipment_provider.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/services/firebase_services.dart';
import 'package:flutter_app_final/utils/equipmentWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
  DateTime _selectedDate = DateTime.now();
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadAdminStatus();
    _loadUserId();
    _loadUserName();
    _loadEvents(); // Cargar los eventos al iniciar// Inicializamos la lista de eventos
    Provider.of<EventProvider>(context, listen: false).loadEvents();
  }

  Future<void> _loadAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getString('email') == 'joariera@gmail.com';
    });
  }

  Future<void> _loadUserName() async {
    if (_userId != null) {
      String? name = await FirebaseServices().getUserNameById(_userId!);
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
        title: const Center(child: Text('Calendario')),
        backgroundColor: const Color(0xFF010618),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFF010618),
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
                  _selectedDate = selectedDay;
                  _loadSelectedEvents(); // Cargar eventos para el día seleccionado
                });
              },
              eventLoader: (day) {
                return events
                    .where((event) => isSameDay(event.date, day))
                    .toList();
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
                  if (events.isNotEmpty) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((event) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            color:
                                Colors.blue, // Color fijo para todos los puntos
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
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
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                withinRangeDecoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: FutureBuilder<List<Event>>(
                future: _getEventsForSelectedDay(
                    eventProvider), // Usamos la función para obtener eventos
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

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        leading: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: event.color ??
                                Colors
                                    .blue, // Usa el color del evento, si no, usa azul
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
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _addEvent(context),
            backgroundColor: const Color(0xFF80B3FF),
            child: const Icon(Icons.add, color: Color(0xFF010618)),
          ),
          const SizedBox(height: 16),
          if (isAdmin)
            FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              backgroundColor: const Color(0xFF80B3FF),
              child: const Icon(Icons.arrow_back, color: Color(0xFF010618)),
            ),
        ],
      ),
    );
  }

  // Cargar eventos para el día seleccionado
  Future<List<Event>> _loadSelectedEvents() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userId = _userId ?? '';

    // Verifica si el usuario tiene eventos para el día seleccionado
    return eventProvider.getEventsForDay(_selectedDate, userId);
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Obtener el ID del usuario logueado
  }

  Future<List<Event>> _getEventsForSelectedDay(
      EventProvider eventProvider) async {
    if (isAdmin) {
      // Si es administrador, obtener todos los eventos
      return eventProvider.getAllEventsForDay(
        _selectedDate,
        isAdmin: isAdmin,
        buildContext: context, // Pasa el contexto aquí
      );
    } else {
      // Obtener el userId desde Firebase Authentication (o de donde corresponda)
      final userId = await _getUserId();
      if (userId != null && _selectedDate != null) {
        return eventProvider.getEventsForDay(_selectedDate, userId);
      }
    }
    return []; // Devuelve una lista vacía si no se cumple ninguna condición
  }

  void _editEvent(BuildContext context, Event event) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final equipmentProvider =
        Provider.of<EquipmentProvider>(context, listen: false);

    TimeOfDay startTime = event.startTime;
    TimeOfDay endTime = event.endTime;

    await equipmentProvider.fetchEquipments();
    List<Equipment> equipmentList = equipmentProvider.equipmentList;

    Equipment? selectedEquipment = equipmentList.firstWhere(
      (e) => e.nameE == event.equipment,
      orElse: () {
        throw Exception('Equipo no encontrado');
      }, // Si no se encuentra, return null
    );

    String eventType = event.title;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Evento'),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
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
                      eventType = newValue;
                    }
                  },
                ),
                EquipmentWidget(
                  selectedEquipment: selectedEquipment,
                  equipmentList: equipmentList,
                  onChanged: (equipment) {
                    if (equipment != null) {
                      selectedEquipment = equipment;
                    }
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
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
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
                equipment: selectedEquipment!.nameE,
                startTime: startTime,
                endTime: endTime,
              );

              eventProvider.editEvent(context, event, updatedEvent);

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deleteEvent(Event event) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este evento?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
            onPressed: () async {
              try {
                await eventProvider.deleteEvent(context, event.date, event);
                Navigator.of(context).pop(); // Cerrar diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Evento eliminado exitosamente')),
                );
              } catch (e) {
                print("Error al eliminar evento: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar el evento')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _addEvent(BuildContext context) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final equipmentProvider =
        Provider.of<EquipmentProvider>(context, listen: false);
    Color selectedColor = Colors.blue; // Valor inicial
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    Equipment? selectedEquipment;
    final userId = await _getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, inicia sesión para agregar un evento.')),
      );
      return;
    }

    await equipmentProvider.fetchEquipments();
    await eventProvider.fetchEvents();

    String eventType = 'Préstamo';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Agregar Evento'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tipo de evento
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
                          eventType = newValue;
                        });
                      }
                    },
                  ),
                  // Selección de color
                  DropdownButton<Color>(
                    value: selectedColor,
                    items: const [
                      DropdownMenuItem(
                        value: Colors.blue,
                        child:
                            Text('Azul', style: TextStyle(color: Colors.blue)),
                      ),
                      DropdownMenuItem(
                        value: Colors.red,
                        child:
                            Text('Rojo', style: TextStyle(color: Colors.red)),
                      ),
                      DropdownMenuItem(
                        value: Colors.green,
                        child: Text('Verde',
                            style: TextStyle(color: Colors.green)),
                      ),
                    ],
                    onChanged: (Color? newColor) {
                      if (newColor != null) {
                        setState(() {
                          selectedColor = newColor;
                        });
                      }
                    },
                  ),
                  // Selección del equipo
                  EquipmentWidget(
                    selectedEquipment: selectedEquipment,
                    equipmentList: equipmentProvider.equipmentList,
                    onChanged: (equipment) {
                      setState(() {
                        selectedEquipment = equipment;
                      });
                    },
                    selectedDate: _selectedDate,
                    startTime: startTime ?? TimeOfDay.now(),
                    endTime: endTime ?? TimeOfDay.now(),
                    userId: userId,
                  ),
                  // Selección de hora de inicio
                  ListTile(
                    title: const Text('Hora de Inicio'),
                    trailing:
                        Text(startTime?.format(context) ?? 'Seleccionar hora'),
                    onTap: () async {
                      final TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (newTime != null) {
                        setState(() {
                          startTime = newTime;
                        });
                      }
                    },
                  ),
                  // Selección de hora de fin
                  ListTile(
                    title: const Text('Hora de Fin'),
                    trailing:
                        Text(endTime?.format(context) ?? 'Seleccionar hora'),
                    onTap: () async {
                      final TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (newTime != null) {
                        setState(() {
                          endTime = newTime;
                        });
                      }
                    },
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
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Agregar'),
                onPressed: () {
                  if (selectedEquipment == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Por favor, selecciona un equipo.')),
                    );
                    return;
                  }
                  if (startTime == null || endTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Por favor, selecciona horas válidas.')),
                    );
                    return;
                  }

                  // Crear un ID único para el evento
                  var uuid = Uuid();
                  String eventId = uuid.v4(); // Genera un ID único

                  Event newEvent = Event(
                    id: eventId, // Asignamos el ID generado
                    title: eventType,
                    equipment: selectedEquipment!.nameE,
                    startTime: startTime!,
                    endTime: endTime!,
                    date: _selectedDay ?? _focusedDay,
                    userId: userId,
                    color: selectedColor, // Se pasa el color seleccionado aquí
                  );
                  eventProvider.addEvent(context, newEvent);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadEvents() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (userProvider.isAdmin) {
      // Obtener todos los eventos para el día
      events = await eventProvider.getAllEventsForDay(_focusedDay);
    } else {
      // Obtener los eventos del usuario para ese día
      final userId = _userId ?? ""; // Usa el userId cargado en el estado
      events = await eventProvider.getEventsForDay(_focusedDay, userId);
    }

    setState(() {}); // Actualizar el estado con los eventos cargados
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }
}
