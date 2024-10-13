import 'package:flutter/material.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Asegúrate de agregar esta librería para formatear fechas

class RentalListPage extends StatefulWidget {
  @override
  _RentalListPageState createState() => _RentalListPageState();
}

class _RentalListPageState extends State<RentalListPage> {
  bool _isLoading = true; // Estado para controlar la carga
  String _errorMessage = ''; // Estado para almacenar errores

  @override
  void initState() {
    super.initState();
    _loadData(); // Cargar los datos cuando se inicia la página
  }

  Future<void> _loadData() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Cargar eventos y usuarios solo una vez
      await Future.wait([
        eventProvider.fetchEvents(),
        userProvider.loadAllUsers(),
      ]);
      setState(() {
        _isLoading = false; // Finalizar carga
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar los datos: $e'; // Manejar errores
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
    final isAdmin = userProvider.isAdmin; // Verifica si es admin
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
              // Si el día de la semana actual ya pasó, sumar días hasta el mismo día de la próxima semana
              dayDate =
                  today.add(Duration(days: (7 - today.weekday + dayIndex)));
            } else if (today.weekday < dayIndex) {
              // Si el día de la semana actual no ha llegado, sumar la diferencia para alcanzar el mismo día de esta semana
              dayDate = today.add(Duration(days: (dayIndex - today.weekday)));
            }

            // Formatear el día para que se muestre como "Lunes 14", etc.
            final dayLabel =
                "${DateFormat('EEEE', 'es').format(dayDate)} ${dayDate.day}";

            // Verificar si es el día actual
            final isToday = dayDate.day == today.day &&
                dayDate.month == today.month &&
                dayDate.year == today.year;

            // Obtener eventos del día correspondiente
            final eventsForDay =
                isAdmin ? eventProvider.getAllEventsForDay(dayDate) : [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    dayLabel.toUpperCase(),
                    style: TextStyle(
                      color: isToday
                          ? Colors.green
                          : Colors.white, // Verde si es hoy
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(color: Colors.white),
                ...eventsForDay.map((event) {
                  final userName = userProvider.getUserNameById(event.userId) ??
                      'Usuario Desconocido';

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
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
          // Recargar eventos
          _loadData();
        },
        backgroundColor: Color(0xFF80B3FF),
        child: Icon(Icons.refresh, color: Color(0xFF010618)),
      ),
    );
  }
}
