import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';
import 'package:path/path.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Obtener todos los equipos de Firestore y sincronizarlos con SQLite
  Future<List<Map<String, dynamic>>> getAllEquipment() async {
    try {
      // Obtener equipos desde Firestore
      QuerySnapshot querySnapshot =
          await _firestore.collection('equipment').get();
      List<Map<String, dynamic>> equipmentList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Sincronizar equipos con SQLite
      for (var equipment in equipmentList) {
        await _dbHelper.addOrUpdateEquipment(equipment);
      }

      return equipmentList;
    } catch (e) {
      print("Error al obtener equipos: $e");
      return [];
    }
  }

// Método para eliminar un evento
  Future<void> deleteEvent(String userId, Event event) async {
    try {
      // Ruta correcta según tu estructura
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(event.id)
          .delete();
      print('Evento eliminado exitosamente');
    } catch (e) {
      print('Error al eliminar evento: $e');
      throw e;
    }
  }

  Future<void> updateEvent(
      Event event, Event updatedEvent, BuildContext context) async {
    if (event.id.isEmpty) {
      throw Exception(
          "El ID del evento está vacío. Verifica que se haya asignado correctamente.");
    }

    // Asegurarse de que el userId esté presente
    if (event.userId.isEmpty) {
      throw Exception(
          "El ID del usuario está vacío. No se puede encontrar la ruta del evento.");
    }

    // Referenciar la ruta correcta en Firestore
    final docRef = _firestore
        .collection('users')
        .doc(event.userId)
        .collection('events')
        .doc(event.id);

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception("No se encontró el documento con ID: ${event.id}");
    }

    // Actualizamos el evento en Firestore
    await docRef.update(updatedEvent.toJson());
    print('Evento actualizado exitosamente en Firestore');

    // Actualizamos el evento en la base de datos local
    final result = await _dbHelper.updateEvent(updatedEvent);
    if (result > 0) {
      print('Evento actualizado exitosamente en SQLite');
    } else {
      throw Exception("Error al actualizar el evento en SQLite");
    }
  }

  // Obtener equipos disponibles para un usuario y fecha
  Future<List<Map<String, dynamic>>> fetchAvailableEquipments(
      String date, String userId) async {
    try {
      // Obtener eventos reservados en Firestore
      QuerySnapshot reservedEventsSnapshot = await _firestore
          .collection('occupied_teams')
          .where('date', isEqualTo: date)
          .get();

      Set<int> reservedIds = reservedEventsSnapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['equipmentId'] as int)
          .toSet();

      Set<int> userReservedIds = reservedEventsSnapshot.docs
          .where(
              (doc) => (doc.data() as Map<String, dynamic>)['userId'] == userId)
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['equipmentId'] as int)
          .toSet();

      // Obtener todos los equipos de Firestore
      QuerySnapshot allEquipmentsSnapshot =
          await _firestore.collection('equipment').get();
      List<Map<String, dynamic>> availableEquipments =
          allEquipmentsSnapshot.docs
              .where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return !reservedIds.contains(data['id']) ||
                    userReservedIds.contains(data['id']);
              })
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      return availableEquipments;
    } catch (e) {
      print("Error al obtener equipos disponibles: $e");
      return [];
    }
  }

  // Reservar un equipo en Firestore y validarlo
  Future<bool> reserveEquipment(
      int equipmentId,
      String date,
      String userId,
      TimeOfDay startTime,
      TimeOfDay endTime,
      String title,
      Color color,
      String data,
      BuildContext context) async {
    try {
      // Verificar conflictos como antes...
      QuerySnapshot reservedEventsSnapshot = await _firestore
          .collection('events')
          .where('equipmentId', isEqualTo: equipmentId)
          .where('date', isEqualTo: date)
          .get();

      for (var doc in reservedEventsSnapshot.docs) {
        var event = doc.data() as Map<String, dynamic>;
        var eventStartTime =
            TimeOfDay.fromDateTime(DateTime.parse(event['startTime']));
        var eventEndTime =
            TimeOfDay.fromDateTime(DateTime.parse(event['endTime']));

        if ((startTime.hour < eventEndTime.hour &&
                endTime.hour > eventStartTime.hour) ||
            (startTime.hour == eventEndTime.hour &&
                startTime.minute < eventEndTime.minute) ||
            (endTime.hour == eventStartTime.hour &&
                endTime.minute > eventStartTime.minute)) {
          return false; // Conflicto de reserva
        }
      }

      // Crear un nuevo evento
      String eventId = _firestore.collection('events').doc().id;
      Event newEvent = Event(
        id: eventId,
        title: title,
        date: DateTime.parse(date),
        startTime: startTime,
        endTime: endTime,
        color: color,
        userId: userId,
        equipment: equipmentId.toString(),
        data: data,
      );

      // Guardar el evento en Firestore
      await _firestore.collection('events').doc(eventId).set(newEvent.toJson());

      return true;
    } catch (e) {
      print("Error al reservar equipo: $e");
      return false;
    }
  }

  // Liberar un equipo (eliminar la reserva)
  Future<void> freeEquipment(int equipmentId, String date) async {
    try {
      QuerySnapshot eventsSnapshot = await _firestore
          .collection('occupied_teams')
          .where('equipmentId', isEqualTo: equipmentId)
          .where('date', isEqualTo: date)
          .get();

      for (var doc in eventsSnapshot.docs) {
        await doc.reference.delete(); // Eliminar la reserva
      }
    } catch (e) {
      print("Error al liberar equipo: $e");
    }
  }

  // Obtener eventos con detalles de usuario
  Future<List<Map<String, dynamic>>> fetchEventsWithUserDetails(
      String date) async {
    try {
      QuerySnapshot eventsSnapshot = await _firestore
          .collection('events')
          .where('date', isEqualTo: date)
          .get();

      List<Map<String, dynamic>> result = [];
      for (var eventDoc in eventsSnapshot.docs) {
        var event = eventDoc.data() as Map<String, dynamic>;

        // Obtener el usuario y equipo relacionados con el evento
        var userDoc = await _firestore
            .collection('users')
            .doc(event['userId'].toString())
            .get();
        var equipmentDoc = await _firestore
            .collection('equipment')
            .doc(event['equipmentId'].toString())
            .get();

        if (userDoc.exists && equipmentDoc.exists) {
          result.add({
            'userName': userDoc['name'],
            'equipmentName': equipmentDoc['nameE'],
            'date': event['date'],
          });
        } else {
          print("No se encontró el usuario o equipo para el evento.");
        }
      }

      return result;
    } catch (e) {
      print("Error al obtener eventos con detalles de usuario: $e");
      return [];
    }
  }

  // Verificar si un usuario es administrador
  Future<bool> isAdmin(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc.exists && userDoc['isAdmin'] == 1;
    } catch (e) {
      print("Error al verificar si el usuario es admin: $e");
      return false;
    }
  }

  // Obtener el nombre de un usuario por ID
  Future<String> getUserName(String userId) async {
    var userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc['name'] : 'Usuario no encontrado';
  }

  // Obtener todos los usuarios
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Obtener un usuario por email y password
  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
      String email, String password) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null; // Si no existe el usuario, retornamos null
    } else {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    }
  }

  Future<void> saveUserEvents(
      String userId, List<Event> events, BuildContext context) async {
    try {
      if (events.isEmpty) {
        print("Error: La lista de eventos está vacía");
        return;
      }

      // Referencia a la subcolección de eventos del usuario
      CollectionReference userEventsRef =
          _firestore.collection('users').doc(userId).collection('events');

      // Usar un batch para operaciones atómicas
      WriteBatch batch = _firestore.batch();

      for (var event in events) {
        if (event.id.isEmpty) {
          event.id = userEventsRef.doc().id; // Generar un nuevo ID
        }

        batch.set(userEventsRef.doc(event.id), event.toJson());
      }

      await batch.commit();
      print("Eventos guardados correctamente para el usuario $userId");
    } catch (e) {
      print("Error al guardar los eventos: $e");
    }
  }

  /// Obtener todos los eventos de un usuario normal
  Future<List<Event>> getAllEvents(String userId) async {
    try {
      print("Buscando eventos para UID: $userId");
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      final List<Event> events = snapshot.docs.map((doc) {
        print("Evento encontrado: ${doc.data()}");
        return Event.fromFirestore(doc); // Usar fromFirestore aquí
      }).toList();

      return events;
    } catch (e) {
      print("Error al obtener eventos de Firestore: $e");
      return [];
    }
  }

  // Método para obtener equipos ocupados
  Future<Map<DateTime, List<String>>> getOccupiedTeams() async {
    try {
      Map<DateTime, List<String>> occupiedTeams = {};
      QuerySnapshot querySnapshot =
          await _firestore.collection('occupied_teams').get();

      for (var doc in querySnapshot.docs) {
        DateTime date = DateTime.parse(doc.id);
        List<String> teams = List<String>.from(doc['teams']);
        occupiedTeams[date] = teams;
      }

      return occupiedTeams;
    } catch (e) {
      print("Error al obtener equipos ocupados: $e");
      return {};
    }
  }

  // Método para guardar equipos ocupados
  Future<void> saveOccupiedTeams(
      Map<DateTime, List<String>> occupiedTeams) async {
    try {
      // Referencia a la colección de equipos ocupados
      CollectionReference occupiedTeamsRef =
          _firestore.collection('occupied_teams');

      // Limpiar equipos ocupados antes de agregar los nuevos
      WriteBatch batch = _firestore.batch();
      QuerySnapshot querySnapshot = await occupiedTeamsRef.get();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference); // Eliminar equipos ocupados antiguos
      }

      // Agregar los equipos ocupados nuevos
      occupiedTeams.forEach((date, teams) {
        batch.set(
          occupiedTeamsRef.doc(date.toIso8601String()),
          {'teams': teams},
        );
      });

      // Commit de la transacción
      await batch.commit();
    } catch (e) {
      print("Error al guardar equipos ocupados: $e");
    }
  }

  // Método para obtener el nombre del usuario por ID
  Future<String?> getUserNameById(String userId) async {
    try {
      // Accede al documento del usuario en la colección 'users'
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();

      if (snapshot.exists) {
        return snapshot['name'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print("Error al obtener el nombre del usuario: $e");
      return null;
    }
  }

  // Imprimir todos los eventos de un usuario (para depuración)
  Future<void> printAllEvents(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No hay eventos almacenados en Firestore para el usuario.");
      } else {
        for (var doc in querySnapshot.docs) {
          print("Evento: ${doc.data()}");
        }
      }
    } catch (e) {
      print("Error al imprimir eventos: $e");
    }
  }

  // Obtener los eventos de un usuario específico
  Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error al obtener los eventos: $e");
      return [];
    }
  }

  // Obtener todos los eventos para el administrador
  Future<List<Event>> getAllAdminEvents() async {
    List<Event> allEvents = [];
    try {
      // Obtener todos los usuarios
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        var eventsRef = userDoc.reference.collection('events');
        QuerySnapshot eventsSnapshot = await eventsRef.get();

        if (eventsSnapshot.docs.isEmpty) {
          print("El usuario ${userDoc.id} no tiene eventos.");
          continue;
        }

        for (var eventDoc in eventsSnapshot.docs) {
          Event event = Event.fromFirestore(eventDoc); // Usar fromFirestore
          allEvents.add(event);
        }
      }
    } catch (e) {
      print("Error al obtener eventos para administrador: $e");
    }
    return allEvents;
  }

// Obtener todos los eventos para el administrador
  Future<List<Map<String, dynamic>>> getAllEventsForAdmin() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('events').get();
      List<Map<String, dynamic>> eventsList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return eventsList;
    } catch (e) {
      print("Error al obtener todos los eventos: $e");
      return [];
    }
  }
}
