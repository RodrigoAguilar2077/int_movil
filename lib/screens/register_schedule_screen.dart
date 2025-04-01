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

  // Función para agregar horario a Firestore y programar la notificación
  void _addSchedule() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        // Convertir la fecha y hora a Timestamp
        DateTime parsedDate = DateTime.parse(_selectedDate);
        DateTime parsedTime = DateTime.parse(
          "2022-01-01 " + _selectedTime,
        ); // Sólo para manejar la hora
        DateTime scheduleDateTime = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );

        // Crear un objeto Schedule
        Schedule newSchedule = Schedule(
          date: Timestamp.fromDate(parsedDate),
          time: Timestamp.fromDate(parsedTime),
          label: _selectedLabel,
          userID: FirebaseAuth.instance.currentUser?.uid ?? '',
        );

        // Llamar al servicio para agregar el horario y programar la notificación
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

  // Función para mostrar el DatePicker y actualizar la fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = picked.toIso8601String().split('T')[0]; // "yyyy-mm-dd"
      });
    }
  }

  // Función para mostrar el TimePicker y actualizar la hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Horarios del Dispensador"),
        backgroundColor: const Color(0xFF81C784), // Color verde
        centerTitle: true,
        elevation: 6, // Sombra suave
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          // Permite desplazarse en la pantalla
          child: Column(
            children: [
              // Formulario para ingresar la fecha, hora y etiqueta
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de fecha con DatePicker
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
                    // Campo de hora con TimePicker
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
                    // Campo de etiqueta (Dropdown)
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
                    // Botón de agregar horario con animación
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSchedule,
                        child: const Text('Agregar Horario'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50), // Verde
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5, // Sombra
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
