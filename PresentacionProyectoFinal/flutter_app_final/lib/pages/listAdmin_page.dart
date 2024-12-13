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
  Map<DateTime, List<Event>> _eventsByDay = {}; // Agrupar los eventos por día

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

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _errorMessage = 'No se encontró el usuario autenticado.';
          _isLoading = false;
        });
        return;
      }

      final firebaseServices = FirebaseServices();
      final List<Event> allEvents =
          await firebaseServices.getAllEventsForAdmin();

      print("Eventos totales recuperados: ${allEvents.length}");

      if (allEvents.isEmpty) {
        print("No se encontraron eventos.");
      }

      DateTime now = DateTime.now();
      DateTime startOfWeek =
          now.subtract(Duration(days: now.weekday - 1)); // Lunes
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6)); // Domingo

      // Inicializar los días de la semana en _eventsByDay
      _eventsByDay = {};
      for (int i = 0; i < 7; i++) {
        DateTime day = startOfWeek.add(Duration(days: i));
        _eventsByDay[DateTime(day.year, day.month, day.day)] = [];
      }

      // Agrupar los eventos por día
      final Map<DateTime, List<Event>> eventsByDay = {};

      for (var event in allEvents) {
        try {
          final eventDate =
              DateTime.parse(event.date.toIso8601String()).toLocal();
          final dayKey =
              DateTime(eventDate.year, eventDate.month, eventDate.day);

          // Verificación de eventos
          print("Evento: ${event.title} para el ${eventDate}");

          // Filtrar eventos solo para la semana actual
          if (dayKey.isBefore(startOfWeek) || dayKey.isAfter(endOfWeek)) {
            continue;
          }

          eventsByDay.putIfAbsent(dayKey, () => []);
          eventsByDay[dayKey]!.add(event);
        } catch (e) {
          print('Error al convertir la fecha del evento: $e');
        }
      }

      // Agregar eventos por día
      setState(() {
        _eventsByDay = eventsByDay;
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
                    final userName = event.userId ?? 'Usuario desconocido';
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
    );
  }
}
