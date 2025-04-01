import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final Timestamp date;
  final Timestamp time;
  final String label;
  final String userID;

  Schedule({
    required this.date,
    required this.time,
    required this.label,
    required this.userID,
  });

  // Método para convertir los datos del Firestore a un objeto Schedule
  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Schedule(
      date: data['date'] ?? Timestamp.now(),
      time: data['time'] ?? Timestamp.now(),
      label: data['label'] ?? '',
      userID: data['userID'] ?? '',
    );
  }

  // Método para convertir el objeto Schedule a un mapa para agregarlo a Firestore
  Map<String, dynamic> toMap() {
    return {'date': date, 'time': time, 'label': label, 'userID': userID};
  }

  // Método adicional para obtener el DateTime de la fecha y hora combinadas
  DateTime get scheduleDateTime {
    DateTime parsedDate = date.toDate();
    DateTime parsedTime = time.toDate();
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }
}
