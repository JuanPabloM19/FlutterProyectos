import 'package:flutter/material.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();

    // Cargar los usuarios cuando se inicializa la pantalla
    Provider.of<UserProvider>(context, listen: false).loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final userId = userProvider.userId;
    final isAdmin = userProvider
        .isAdmin; // Asegúrate de tener un método para comprobar si el usuario es admin

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Ajustes')),
        backgroundColor: Color(0xFF010618),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Color(0xFF010618),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.transparent,
                child: Column(
                  children: [
                    const ListTile(
                      title: Text(
                        'Datos personales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: Text(
                        userProvider.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.white),
                      title: Text(
                        userProvider.email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Eventos del día',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Consumer<EventProvider>(
                        builder: (context, eventProvider, child) {
                          final eventsToday = isAdmin
                              ? eventProvider.getAllEventsForDay(DateTime.now())
                              : eventProvider.getEventsForDay(
                                  DateTime.now(), userId);

                          if (eventsToday.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: eventsToday.map((event) {
                                // Obtén el nombre del usuario utilizando el UserProvider
                                final userName = Provider.of<UserProvider>(
                                        context,
                                        listen: false)
                                    .getUserNameById(event.userId);

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10.0,
                                        height: 10.0,
                                        decoration: BoxDecoration(
                                          color: event.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          "$userName - ${event.equipment} - ${event.startTime.format(context)} a ${event.endTime.format(context)}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          } else {
                            return Text(
                              'Hoy no se registraron eventos',
                              style: TextStyle(color: Colors.white),
                            );
                          }
                        },
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 30.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Recargar eventos desde SharedPreferences
                        Provider.of<EventProvider>(context, listen: false)
                            .loadEvents();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF80B3FF),
                        foregroundColor: Color(0xFF010618),
                      ),
                      child: Text('Recargar Eventos'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
