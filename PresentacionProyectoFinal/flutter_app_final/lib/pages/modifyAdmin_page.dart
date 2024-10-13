import 'package:flutter/material.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:provider/provider.dart';

class ModifyEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events; // Obtén todos los eventos

    return Scaffold(
      appBar: AppBar(title: Text('Modificar Eventos')),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event.equipment),
            subtitle: Text('${event.startTime.format(context)} - ${event.endTime.format(context)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Implementar la lógica para editar el evento
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Implementar la lógica para eliminar el evento
                    eventProvider.deleteEvent(context, event.date, event);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
