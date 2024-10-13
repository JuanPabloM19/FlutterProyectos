import 'package:flutter/material.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import 'package:intl/intl.dart'; // Importa el paquete para formatear fechas

class RentalListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.isAdmin; // Verifica si el usuario es admin

    // Lista de días de la semana
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
            // Obtener el número del día en la semana (Lunes = 1, Domingo = 7)
            int dayIndex = daysOfWeek.indexOf(day) + 1;

            // Obtener la fecha de hoy y calcular la fecha correspondiente
            DateTime today = DateTime.now();
            DateTime dayDate = today;

            // Ajustar la fecha para que apunte al día correcto de esta semana o la siguiente
            if (today.weekday > dayIndex) {
              dayDate =
                  today.add(Duration(days: (7 - today.weekday + dayIndex)));
            } else if (today.weekday < dayIndex) {
              dayDate = today.add(Duration(days: (dayIndex - today.weekday)));
            }

            // Formatear la fecha para mostrar el día del mes
            String formattedDate =
                DateFormat('d').format(dayDate); // Muestra el número del día

            // Obtener eventos del día correspondiente
            final eventsForDay =
                isAdmin ? eventProvider.getAllEventsForDay(dayDate) : [];

            // Verificar si es el día actual
            bool isToday = dayDate.day == today.day &&
                dayDate.month == today.month &&
                dayDate.year == today.year;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Margen horizontal
                  child: Text(
                    '${day.toUpperCase()} $formattedDate', // Mostrar el nombre del día y el número
                    style: TextStyle(
                      color: isToday
                          ? Colors.green
                          : Colors.white, // Día actual en verde
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(color: Colors.white),
                ...eventsForDay.map((event) {
                  // Obtener el nombre del usuario utilizando el UserProvider
                  final userName = userProvider.getUserNameById(event.userId);

                  return ListTile(
                    title: Text(
                      'Usuario: $userName',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Equipo: ${event.equipment}\n' +
                          'Horario: ${event.startTime.format(context)} a ${event.endTime.format(context)}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    tileColor: Colors.green.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  );
                }).toList(),
                if (eventsForDay.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0), // Margen horizontal
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No hay alquileres para este día.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Recargar eventos desde SharedPreferences
          Provider.of<EventProvider>(context, listen: false).loadEvents();
        },
        backgroundColor: Color(0xFF80B3FF),
        child: Icon(Icons.refresh, color: Color(0xFF010618)),
      ),
    );
  }
}
