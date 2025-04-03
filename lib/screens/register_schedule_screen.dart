import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:int_movil/models/schedule_model.dart';
import 'package:int_movil/services/schedule_service.dart';

class RegisterScheduleScreen extends StatefulWidget {
  const RegisterScheduleScreen({super.key});

  @override
  _RegisterScheduleScreenState createState() => _RegisterScheduleScreenState();
}

class _RegisterScheduleScreenState extends State<RegisterScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedDate;
  late String _selectedTime;
  late String _selectedLabel;

  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    _selectedDate = '';
    _selectedTime = '';
    _selectedLabel = '';
  }

  void _addSchedule() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        DateTime parsedDate = DateTime.parse(_selectedDate);
        List<String> timeParts = _selectedTime.split(":");
        TimeOfDay timeOfDay = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );

        DateTime scheduleDateTime = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );

        Schedule newSchedule = Schedule(
          dateTime: Timestamp.fromDate(scheduleDateTime),
          label: _selectedLabel,
          userID: FirebaseAuth.instance.currentUser?.uid ?? '',
        );

        await _scheduleService.addSchedule(newSchedule);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horario agregado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar el horario: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = "${picked.hour}:${picked.minute}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registrar Horarios del Dispensador",
          style: TextStyle(
            fontFamily: 'Fjalla One', // Aquí se aplica la fuente
          ),
        ),
        backgroundColor: const Color(0xFF81C784),
        centerTitle: true,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText:
                                _selectedDate.isEmpty
                                    ? 'Seleccione la Fecha'
                                    : _selectedDate,
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText:
                                _selectedTime.isEmpty
                                    ? 'Seleccione la Hora'
                                    : _selectedTime,
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Etiqueta (Desayuno, Comida, Cena, etc.)',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedLabel.isEmpty ? null : _selectedLabel,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLabel = newValue ?? '';
                        });
                      },
                      items:
                          <String>[
                            'Desayuno',
                            'Comida',
                            'Cena',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSchedule,
                        child: const Text('Agregar Horario'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
