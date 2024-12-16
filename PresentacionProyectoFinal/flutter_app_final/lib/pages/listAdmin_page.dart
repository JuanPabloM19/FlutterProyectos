import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:flutter_app_final/services/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'today_page.dart';

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
    _loadData();
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      QuerySnapshot nameSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('name')
          .limit(1)
          .get();

      QuerySnapshot emailSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('email')
          .limit(1)
          .get();

      // Verificar si se obtuvo un documento en cada subcolección
      DocumentSnapshot? nameDoc =
          nameSnapshot.docs.isNotEmpty ? nameSnapshot.docs.first : null;

      DocumentSnapshot? emailDoc =
          emailSnapshot.docs.isNotEmpty ? emailSnapshot.docs.first : null;

      return {
        'name': nameDoc != null ? nameDoc['name'] : 'Usuario desconocido',
        'email': emailDoc != null ? emailDoc['email'] : 'Email desconocido',
      };
    } catch (e) {
      print('Error obteniendo los detalles del usuario: $e');
      return {'name': 'Usuario desconocido', 'email': 'Email desconocido'};
    }
  }

  Future<void> _loadData() async {
    try {
      final firebaseServices = FirebaseServices();
      final List<Event> allEvents =
          await firebaseServices.getAllEventsForAdmin();

      DateTime now = DateTime.now();
      DateTime startOfWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

      _eventsByDay = {};
      for (int i = 0; i < 7; i++) {
        DateTime day = startOfWeek.add(Duration(days: i));
        _eventsByDay[DateTime(day.year, day.month, day.day)] = [];
      }

      for (var event in allEvents) {
        final eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);
        final dayKey = DateTime(eventDate.year, eventDate.month, eventDate.day);

        if (dayKey.isBefore(startOfWeek) || dayKey.isAfter(endOfWeek)) {
          continue;
        }

        _eventsByDay.putIfAbsent(dayKey, () => []);
        _eventsByDay[dayKey]!.add(event);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error global en _loadData: $e');
      setState(() {
        _errorMessage = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

              print("Eventos para el ${dayLabel}: ${eventsForDay.length}");

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
                      return FutureBuilder<Map<String, dynamic>>(
                        future: getUserDetails(event.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              title: Text('Cargando usuario...'),
                              subtitle: Text('Equipo: ${event.equipment}'),
                            );
                          }

                          DateTime startDateTime = DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              event.startTime.hour,
                              event.startTime.minute);
                          DateTime endDateTime = DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              event.endTime.hour,
                              event.endTime.minute);

                          if (snapshot.hasData) {
                            final user = snapshot.data!;
                            return ListTile(
                              title: Text('Usuario: ${user['name']}',
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                'Email: ${user['email']}\nEquipo: ${event.equipment}\nHorario: ${DateFormat('HH:mm').format(startDateTime)} a ${DateFormat('HH:mm').format(endDateTime)}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              tileColor: Colors.green.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                            );
                          } else {
                            return ListTile(
                              title: Text('Usuario desconocido'),
                              subtitle: Text(
                                  'Equipo: ${event.equipment}\nHorario: ${DateFormat('HH:mm').format(startDateTime)} a ${DateFormat('HH:mm').format(endDateTime)}'),
                            );
                          }
                        },
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                );
              },
              backgroundColor: Color(0xFF80B3FF),
              child: Icon(Icons.add, color: Color(0xFF010618)),
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {
                _loadData();
              },
              backgroundColor: Color(0xFF80B3FF),
              child: Icon(Icons.refresh, color: Color(0xFF010618)),
            ),
          ],
        ));
  }
}
