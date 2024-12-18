import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    if (event.userId.isEmpty) {
      throw Exception(
          "El ID del usuario está vacío. No se puede encontrar la ruta del evento.");
    }

    final docRef = _firestore
        .collection('users')
        .doc(event.userId)
        .collection('events')
        .doc(event.id);

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception("No se encontró el documento con ID: ${event.id}");
    }

    await docRef.update(updatedEvent.toJson());
    print('Evento actualizado exitosamente en Firestore');

    final result = await _dbHelper.updateEvent(updatedEvent);
    if (result > 0) {
      print('Evento actualizado exitosamente en SQLite');
    } else {
      throw Exception("Error al actualizar el evento en SQLite");
    }
  }

  // Obtener equipos disponibles para una fecha específica
  Future<List<Map<String, dynamic>>> fetchAvailableEquipments(
      String date) async {
    try {
      QuerySnapshot allEquipmentsSnapshot =
          await _firestore.collection('equipment').get();

      List<Map<String, dynamic>> availableEquipments = allEquipmentsSnapshot
          .docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((equipment) {
        var reservedDatesData = equipment['reservedDates'];
        List<String> reservedDates = (reservedDatesData is List)
            ? List<String>.from(reservedDatesData)
            : [];

        // Verificar si la fecha está reservada
        return !reservedDates.contains(date);
      }).toList();

      return availableEquipments;
    } catch (e) {
      print("Error al obtener equipos disponibles: $e");
      return [];
    }
  }

  // Reservar un equipo en Firestore
  Future<bool> reserveEquipment(
    int equipmentId,
    String date,
    String userId,
    String title,
    TimeOfDay startTime,
    TimeOfDay endTime,
    Color color,
    String data,
    BuildContext context,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference equipmentRef =
            _firestore.collection('equipment').doc(equipmentId.toString());

        DocumentSnapshot equipmentSnapshot =
            await transaction.get(equipmentRef);

        if (!equipmentSnapshot.exists) {
          throw Exception("Equipo no encontrado");
        }

        Map<String, dynamic> equipmentData =
            equipmentSnapshot.data() as Map<String, dynamic>;

        List<String> reservedDates =
            List<String>.from(equipmentData['reservedDates'] ?? []);

        // Verificar si el equipo está disponible en esa fecha
        if (reservedDates.contains(date)) {
          throw Exception("El equipo ya está reservado para esta fecha.");
        }

        transaction.update(equipmentRef, {
          'reservedDates': FieldValue.arrayUnion([date])
        });

        String eventId = _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc()
            .id;

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

        DocumentReference eventRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(eventId);
        transaction.set(eventRef, newEvent.toJson());
      });

      return true;
    } catch (e) {
      print("Error al reservar equipo: $e");
      return false;
    }
  }

  // Liberar un equipo (eliminar la reserva)
  Future<void> freeEquipment(int equipmentId, String date) async {
    try {
      DocumentReference equipmentRef =
          _firestore.collection('equipment').doc(equipmentId.toString());

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot equipmentSnapshot =
            await transaction.get(equipmentRef);
        if (!equipmentSnapshot.exists) throw Exception("Equipo no encontrado");

        transaction.update(equipmentRef, {
          'reservedDates': FieldValue.arrayRemove([date])
        });
      });
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
      return null;
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

      CollectionReference userEventsRef =
          _firestore.collection('users').doc(userId).collection('events');

      // Usar un batch para operaciones atómicas
      WriteBatch batch = _firestore.batch();

      for (var event in events) {
        if (event.id.isEmpty) {
          event.id = userEventsRef.doc().id;
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
    if (userId.isEmpty || userId == '0') {
      print("Error: El UID no está definido correctamente");
      userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    }
    try {
      print("Buscando eventos para UID: $userId");
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      final List<Event> events = snapshot.docs.map((doc) {
        print("Evento encontrado: ${doc.data()}");
        return Event.fromFirestore(doc);
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
      CollectionReference occupiedTeamsRef =
          _firestore.collection('occupied_teams');

      WriteBatch batch = _firestore.batch();
      QuerySnapshot querySnapshot = await occupiedTeamsRef.get();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      occupiedTeams.forEach((date, teams) {
        batch.set(
          occupiedTeamsRef.doc(date.toIso8601String()),
          {'teams': teams},
        );
      });

      await batch.commit();
    } catch (e) {
      print("Error al guardar equipos ocupados: $e");
    }
  }

  // Método para obtener el nombre del usuario por ID
  Future<String?> getUserNameById(String userId) async {
    try {
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
  Future<List<Event>> getUserEvents(String userId) async {
    List<Event> userEvents = [];
    try {
      final eventsRef =
          _firestore.collection('users').doc(userId).collection('events');
      final eventsSnapshot = await eventsRef.get();

      if (eventsSnapshot.docs.isNotEmpty) {
        userEvents = eventsSnapshot.docs
            .map((eventDoc) {
              try {
                return Event.fromFirestore(eventDoc);
              } catch (e) {
                print('Error al convertir evento para el usuario $userId: $e');
                return null;
              }
            })
            .whereType<Event>()
            .toList();
      }

      print("Eventos cargados para el usuario $userId: ${userEvents.length}");
    } catch (e) {
      print("Error al obtener eventos del usuario $userId: $e");
    }

    return userEvents;
  }

  // Obtener todos los eventos para el administrador
  Future<List<Event>> getAllAdminEvents() async {
    List<Event> allEvents = [];
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      List<Future<List<Event>>> eventFutures =
          usersSnapshot.docs.map((userDoc) async {
        var eventsRef = userDoc.reference.collection('events');
        QuerySnapshot eventsSnapshot = await eventsRef.get();

        return eventsSnapshot.docs.map((eventDoc) {
          return Event.fromFirestore(eventDoc);
        }).toList();
      }).toList();

      List<List<Event>> allUsersEvents = await Future.wait(eventFutures);

      allEvents = allUsersEvents.expand((events) => events).toList();
    } catch (e) {
      print("Error al obtener eventos para administrador: $e");
    }
    return allEvents;
  }

  Future<bool> checkIfUserIsAdmin(String userId) async {
    try {
      final idTokenResult =
          await FirebaseAuth.instance.currentUser!.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      final isAdmin = claims?['admin'] == true;
      print("El usuario con UID: $userId es Admin? $isAdmin");
      return isAdmin;
    } catch (e) {
      print("Error al verificar si el usuario es admin: $e");
      return false;
    }
  }

  Future<List<Event>> getAllEventsForAdmin() async {
    List<Event> allEvents = [];
    try {
      final querySnapshot = await _firestore.collectionGroup('events').get();
      print(
          'Total de documentos de eventos recuperados: ${querySnapshot.docs.length}');

      allEvents = querySnapshot.docs
          .map((doc) {
            try {
              return Event.fromFirestore(doc);
            } catch (e) {
              print('Error al convertir evento: $e');
              return null;
            }
          })
          .where((event) => event != null)
          .cast<Event>()
          .toList();

      print('Total de eventos convertidos: ${allEvents.length}');

      // FILTRO DE LA SEMANA ACTUAL
      List<DateTime> weekDates = getWeekDates();
      DateTime startDate = weekDates.first;
      DateTime endDate = weekDates.last;

      allEvents = allEvents.where((event) {
        final eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);
        return eventDate.isAfter(startDate.subtract(Duration(days: 1))) &&
            eventDate.isBefore(endDate.add(Duration(days: 1)));
      }).toList();

      print('Total de eventos de la semana actual: ${allEvents.length}');
    } catch (e) {
      print('Error al obtener todos los eventos: $e');
    }
    return allEvents;
  }

  List<DateTime> getWeekDates() {
    DateTime today = DateTime.now();
    int currentDayOfWeek = today.weekday; // 1 (lunes) a 7 (domingo)
    DateTime startOfWeek = today.subtract(Duration(days: currentDayOfWeek - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }
}
