import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/pages/today_page.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:flutter_app_final/services/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RentalListPage extends StatefulWidget {
  @override
  _RentalListPageState createState() => _RentalListPageState();
}

class _RentalListPageState extends State<RentalListPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<DateTime, List<Event>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _loadData(); // Cargar datos al iniciar
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _eventsByDay.clear();
    });

    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final isAdmin = userProvider.isAdmin;

      if (isAdmin) {
        final firebaseServices = FirebaseServices();
        final allEvents = await firebaseServices.getAllEventsForAdmin();

        // Agrupar los eventos por día
        final Map<DateTime, List<Event>> eventsByDay = {};
        for (var eventData in allEvents) {
          final eventDate =
              DateTime.parse(eventData['date']).toLocal(); // ⚠️ Importante
          final dayKey =
              DateTime(eventDate.year, eventDate.month, eventDate.day);

          // Asegurar la creación de la lista antes de añadir
          eventsByDay
              .putIfAbsent(dayKey, () => [])
              .add(Event.fromJson(eventData));
        }

        setState(() {
          _eventsByDay = eventsByDay;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Listado de Alquileres')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Listado de Alquileres')),
        body: Center(child: Text(_errorMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('Listado de Alquileres')),
        backgroundColor: const Color(0xFF010618),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFF010618),
        child: ListView(
          children: _eventsByDay.entries.map((entry) {
            DateTime dayDate = entry.key;
            List<Event> eventsForDay = entry.value ?? [];

            final dayLabel =
                "${DateFormat('EEEE', 'es').format(dayDate)} ${dayDate.day}";
            final isToday = dayDate.day == DateTime.now().day &&
                dayDate.month == DateTime.now().month &&
                dayDate.year == DateTime.now().year;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    dayLabel.toUpperCase(),
                    style: TextStyle(
                      color: isToday ? Colors.green : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(color: Colors.white),
                if (eventsForDay.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No hay alquileres para este día.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  ...eventsForDay.map((event) {
                    final userName =
                        userProvider.getUserNameById(event.userId) ??
                            'Usuario desconocido';

                    // Crear DateTime temporal para formatear la hora
                    DateTime startDateTime = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      event.startTime.hour,
                      event.startTime.minute,
                    );
                    DateTime endDateTime = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      event.endTime.hour,
                      event.endTime.minute,
                    );

                    return ListTile(
                      title: Text('Usuario: $userName',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        'Equipo: ${event.equipment}\nHorario: ${DateFormat('HH:mm').format(startDateTime)} a ${DateFormat('HH:mm').format(endDateTime)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      tileColor: Colors.green.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    );
                  }).toList(),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addEvent', // Asignar un tag único
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
            backgroundColor: const Color(0xFF80B3FF),
            child: const Icon(Icons.add, color: Color(0xFF010618)),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'refreshEvents', // Asignar otro tag único
            onPressed: () async {
              final eventProvider =
                  Provider.of<EventProvider>(context, listen: false);
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Actualizando eventos...'),
                  duration: Duration(seconds: 2),
                ),
              );

              try {
                final isAdmin = userProvider.isAdmin;
                if (isAdmin) {
                  eventProvider.fetchEvents(isAdmin: true);
                } else {
                  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                  eventProvider.fetchUserEventsFromFirebase(context, userId);
                }
                _loadData(); // Recargar vista después de actualizar los datos

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Eventos actualizados correctamente'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar eventos: $e'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            backgroundColor: const Color(0xFF80B3FF),
            child: const Icon(Icons.refresh, color: Color(0xFF010618)),
          ),
        ],
      ),
    );
  }
}
