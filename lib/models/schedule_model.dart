import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final Timestamp dateTime; // Un solo campo para la fecha y hora
  final String label;
  final String userID;

  Schedule({required this.dateTime, required this.label, required this.userID});

  // Método para convertir los datos del Firestore a un objeto Schedule
  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Schedule(
      dateTime: data['dateTime'] ?? Timestamp.now(),
      label: data['label'] ?? '',
      userID: data['userID'] ?? '',
    );
  }

  // Método para convertir el objeto Schedule a un mapa para agregarlo a Firestore
  Map<String, dynamic> toMap() {
    return {'dateTime': dateTime, 'label': label, 'userID': userID};
  }

  // Método adicional para obtener el DateTime combinado de fecha y hora
  DateTime get scheduleDateTime {
    return dateTime.toDate();
  }
}
