import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = loadData(); // Cargar los datos al iniciar
  }

  Future<void> loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    await userProvider.loadAllUsers();
    await eventProvider.fetchEvents(); // Asegurarse de cargar los eventos
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final userId = userProvider.userId;
    final isAdmin = userProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Ajustes')),
        backgroundColor: Color(0xFF010618),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Color(0xFF010618),
        child: FutureBuilder<void>(
          future: _loadDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView(
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
                            leading:
                                const Icon(Icons.person, color: Colors.white),
                            title: Text(
                              userProvider.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.email, color: Colors.white),
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
                                return FutureBuilder<List<Event>>(
                                  future: eventProvider.getEventsForDay(
                                      DateTime.now(),
                                      userId), // Asegúrate de pasar userId
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}',
                                          style:
                                              TextStyle(color: Colors.white));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Text(
                                          'Hoy no se registraron eventos',
                                          style:
                                              TextStyle(color: Colors.white));
                                    } else {
                                      final eventsToday = snapshot.data!;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: eventsToday.map((event) {
                                          final userName = userProvider
                                              .getUserNameById(event.userId);

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
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
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          const Divider(
                              color: Colors.transparent, height: 30.0),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _loadDataFuture = eventProvider.fetchEvents();
                              });
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
              );
            }
          },
        ),
      ),
    );
  }
}
