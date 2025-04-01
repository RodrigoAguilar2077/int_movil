import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:int_movil/models/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Eliminar la inicialización de FlutterLocalNotificationsPlugin

  ScheduleService();

  // Función para agregar un nuevo horario en Firestore
  Future<void> addSchedule(Schedule schedule) async {
    try {
      // Guardamos el horario en Firestore
      await _firestore.collection('schedules').add(schedule.toMap());
      // Ya no se programa la notificación
    } catch (e) {
      throw Exception('Error al agregar el horario: $e');
    }
  }

  // Eliminar la función _scheduleNotification
}
