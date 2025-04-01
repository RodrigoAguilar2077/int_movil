import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late String userID;
  late DateTime selectedDate;
  Map<DateTime, List<Map<String, String>>> _events =
      {}; // Almacenar eventos por fecha con horario
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    userID = FirebaseAuth.instance.currentUser?.uid ?? '';
    selectedDate = DateTime.now();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('schedules')
              .where('userID', isEqualTo: userID)
              .get();

      final events = <DateTime, List<Map<String, String>>>{};
      for (var doc in snapshot.docs) {
        Timestamp dateTimestamp = doc['date'];
        DateTime eventDate = dateTimestamp.toDate();

        DateTime cleanedEventDate = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
        );

        String label = doc['label'];
        String time = doc['time']; // Obtener horario específico del evento

        if (events[cleanedEventDate] == null) {
          events[cleanedEventDate] = [];
        }

        events[cleanedEventDate]?.add({"label": label, "time": time});
      }

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar eventos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      selectedDate = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime cleanedSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendario de Horarios"),
        backgroundColor: const Color.fromARGB(197, 233, 189, 105),
      ),
      body: Container(
        color: Color.fromARGB(255, 120, 114, 105), // Fondo gris oscuro
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Calendario
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: selectedDate,
                          selectedDayPredicate: (day) {
                            return isSameDay(selectedDate, day);
                          },
                          onDaySelected: _onDaySelected,
                          eventLoader: (day) {
                            DateTime cleanedDay = DateTime(
                              day.year,
                              day.month,
                              day.day,
                            );
                            return _events[cleanedDay]
                                    ?.map((e) => e["label"])
                                    .toList() ??
                                [];
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: Colors.blue,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: Colors.blue,
                            ),
                          ),
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            weekendTextStyle: TextStyle(color: Colors.red),
                            todayTextStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Eventos del día seleccionado
                      Expanded(
                        child:
                            _events[cleanedSelectedDate]?.isNotEmpty ?? false
                                ? ListView.builder(
                                  itemCount:
                                      _events[cleanedSelectedDate]!.length,
                                  itemBuilder: (context, index) {
                                    final event =
                                        _events[cleanedSelectedDate]![index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(
                                          15,
                                        ),
                                        title: Text(event["label"] ?? ""),
                                        subtitle: Text(
                                          "Horario: ${event["time"] ?? "Sin horario"}",
                                        ),
                                        leading: const Icon(
                                          Icons.event,
                                          color: Colors.blue,
                                        ),
                                        tileColor: Colors.grey[50],
                                      ),
                                    );
                                  },
                                )
                                : Center(
                                  child: const Text(
                                    'No hay horarios programados para este día.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
