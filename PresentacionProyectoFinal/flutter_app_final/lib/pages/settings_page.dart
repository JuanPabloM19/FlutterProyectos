import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Ajustes')),
        backgroundColor: Color(0xFF010618), // Fondo del AppBar
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Color(0xFF010618), // Fondo de la pantalla
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.transparent, // Hacer el Card transparente
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Datos personales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24, // Tamaño de texto aumentado
                          fontWeight: FontWeight.bold, // Negrita
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.person,
                          color: Colors.white), // Icono de nombre
                      title: Text(
                        'Sr Ejemplo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Tamaño de texto aumentado
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.email,
                          color: Colors.white), // Icono de correo
                      title: Text(
                        'srejemplo123@gmail.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Tamaño de texto aumentado
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
                color: Colors.transparent, // Hacer el Card transparente
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Eventos del día',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24, // Tamaño de texto aumentado
                          fontWeight: FontWeight.bold, // Negrita
                        ),
                      ),
                      subtitle: Consumer<EventProvider>(
                        builder: (context, eventProvider, child) {
                          final eventsToday =
                              eventProvider.getEventsForDay(DateTime.now());
                          if (eventsToday.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: eventsToday.map((event) {
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
                                      SizedBox(
                                          width:
                                              8.0), // Espacio entre el punto y el texto
                                      Expanded(
                                        child: Text(
                                          "${event.title} - ${event.startTime.format(context)} a ${event.endTime.format(context)}",
                                          style: TextStyle(
                                            fontSize:
                                                16, // Tamaño de texto aumentado
                                            color:
                                                Colors.white, // Texto en blanco
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
                              style: TextStyle(
                                  color: Colors.white), // Texto en blanco
                            );
                          }
                        },
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent, // Cambiado a transparente
                      height: 30.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Recargar eventos desde SharedPreferences
                        Provider.of<EventProvider>(context, listen: false)
                            .loadEvents();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF80B3FF), // Color de fondo azul claro
                        foregroundColor:
                            Color(0xFF010618), // Color del texto negro
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
