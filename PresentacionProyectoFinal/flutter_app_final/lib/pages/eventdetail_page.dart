import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Evento'),
        backgroundColor: const Color(0xFF010618),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Fecha: ${event.date.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Hora Inicio: ${event.startTime.format(context)}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Hora Fin: ${event.endTime.format(context)}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper().getUserDetailsByReservationDate(
                  DateFormat('yyyy-MM-dd').format(event.date)),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Cargando usuario...',
                    style: TextStyle(color: Colors.white),
                  );
                } else if (userSnapshot.hasError) {
                  return const Text(
                    'Error al cargar usuario',
                    style: TextStyle(color: Colors.white),
                  );
                } else if (!userSnapshot.hasData ||
                    userSnapshot.data!.isEmpty) {
                  return const Text(
                    'No se encontró información',
                    style: TextStyle(color: Colors.white),
                  );
                }

                final userDetails = userSnapshot.data!.first;
                final userName = userDetails['name'] ?? 'Usuario no encontrado';
                final equipmentName =
                    userDetails['nameE'] ?? 'Equipo no encontrado';

                return Text(
                  'Usuario: $userName\nEquipo: $equipmentName',
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
