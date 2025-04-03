import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditDietScreen extends StatefulWidget {
  final String petId;

  const AddEditDietScreen({Key? key, required this.petId}) : super(key: key);

  @override
  _AddEditDietScreenState createState() => _AddEditDietScreenState();
}

class _AddEditDietScreenState extends State<AddEditDietScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController();
  final _restrictionsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedType;
  String? _selectedRestriction;

  // Opciones predefinidas
  final List<String> _typeOptions = ['Seco', 'Húmedo', 'Mixto'];
  final List<String> _restrictionOptions = [
    'Sin gluten',
    'Sin cereales',
    'Con proteína de pollo',
    'Otro',
    'NA',
  ];

  Future<DocumentSnapshot?> _getDietData() async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance
              .collection('dietas')
              .where('mascotaid', isEqualTo: widget.petId)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
    } catch (e) {
      print("Error al obtener dieta: $e");
    }
    return null;
  }

  Future<void> _saveDiet() async {
    if (_formKey.currentState!.validate()) {
      try {
        var dietData = await _getDietData();
        if (dietData != null) {
          await FirebaseFirestore.instance
              .collection('dietas')
              .doc(dietData.id)
              .update({
                'tipo': _selectedType,
                'marca': _brandController.text,
                'cantidad': double.tryParse(_quantityController.text) ?? 0,
                'restricciones':
                    _selectedRestriction == 'Otro'
                        ? _restrictionsController.text
                        : _selectedRestriction,
                'notas': _notesController.text,
              });
        } else {
          await FirebaseFirestore.instance.collection('dietas').add({
            'mascotaid': widget.petId,
            'tipo': _selectedType,
            'marca': _brandController.text,
            'cantidad': double.tryParse(_quantityController.text) ?? 0,
            'restricciones':
                _selectedRestriction == 'Otro'
                    ? _restrictionsController.text
                    : _selectedRestriction,
            'notas': _notesController.text,
          });
        }

        // Mostrar SnackBar con mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dieta guardada correctamente')),
        );

        // Regresar a la página anterior
        Navigator.pop(context);
      } catch (e) {
        print("Error al guardar dieta: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDietData();
  }

  Future<void> _loadDietData() async {
    var dietData = await _getDietData();
    if (dietData != null) {
      setState(() {
        _selectedType = dietData['tipo'] ?? '';
        _selectedRestriction = dietData['restricciones'] ?? '';
        _brandController.text = dietData['marca'] ?? '';
        _quantityController.text = dietData['cantidad'].toString();
        _notesController.text = dietData['notas'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar/Editar Dieta'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de comida'),
                items:
                    _typeOptions.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedRestriction,
                decoration: const InputDecoration(
                  labelText: 'Restricciones alimenticias',
                ),
                items:
                    _restrictionOptions.map((String restriction) {
                      return DropdownMenuItem<String>(
                        value: restriction,
                        child: Text(restriction),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRestriction = newValue;
                    if (newValue != null && newValue == 'Otro') {
                      _restrictionsController.text = '';
                    }
                  });
                },
              ),
              if (_selectedRestriction == 'Otro')
                TextFormField(
                  controller: _restrictionsController,
                  decoration: const InputDecoration(
                    labelText: 'Escribe tu propia restricción',
                  ),
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marca de la comida',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad (gramos por comida)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDiet,
                child: const Text('Guardar Dieta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
