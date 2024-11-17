import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'today_page.dart'; // Asegúrate de que la importación sea correcta

class RentalListPage extends StatefulWidget {
  @override
  _RentalListPageState createState() => _RentalListPageState();
}

class _RentalListPageState extends State<RentalListPage> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await Future.wait([
        eventProvider.fetchEvents(),
        userProvider.loadAllUsers(),
      ]);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar los datos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Listado de Alquileres')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Listado de Alquileres')),
        body: Center(child: Text(_errorMessage)),
      );
    }

    return _buildRentalList(context, eventProvider, userProvider);
  }

  Widget _buildRentalList(BuildContext context, EventProvider eventProvider,
      UserProvider userProvider) {
    final isAdmin = userProvider.isAdmin;
    final List<String> daysOfWeek = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Listado de Alquileres')),
        backgroundColor: Color(0xFF010618),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Color(0xFF010618),
        child: ListView(
          children: daysOfWeek.map((day) {
            int dayIndex = daysOfWeek.indexOf(day) + 1;
            DateTime today = DateTime.now();
            DateTime dayDate = today;

            if (today.weekday > dayIndex) {
              dayDate =
                  today.add(Duration(days: (7 - today.weekday + dayIndex)));
            } else if (today.weekday < dayIndex) {
              dayDate = today.add(Duration(days: (dayIndex - today.weekday)));
            }

            final dayLabel =
                "${DateFormat('EEEE', 'es').format(dayDate)} ${dayDate.day}";
            final isToday = dayDate.day == today.day &&
                dayDate.month == today.month &&
                dayDate.year == today.year;

            return FutureBuilder<List<Event>>(
              future: isAdmin
                  ? eventProvider.getAllEventsForDay(dayDate)
                  : Future.value([]), // Si no es admin, no cargamos eventos
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No hay alquileres para este día.',
                              style: TextStyle(color: Colors.white70)),
                        ),
                      ),
                    ],
                  );
                }

                List<Event> eventsForDay = snapshot.data!;

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
                    ...eventsForDay.map((event) {
                      final userName =
                          userProvider.getUserNameById(event.userId);
                      return ListTile(
                        title: Text('Usuario: $userName',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Equipo: ${event.equipment}\nHorario: ${event.startTime.format(context)} a ${event.endTime.format(context)}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        tileColor: Colors.green.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      );
                    }).toList(),
                  ],
                );
              },
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
                  MaterialPageRoute(
                      builder: (context) => const CalendarPage()));
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
      ),
    );
  }
}
