import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class EditPetScreen extends StatefulWidget {
  final Map<String, dynamic> petData; // Información inicial de la mascota
  final String petId; // ID único del documento en Firestore

  const EditPetScreen({required this.petData, required this.petId, super.key});

  @override
  _EditPetScreenState createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _traitsController;
  late TextEditingController _breedController;
  late TextEditingController _healthController;
  String _selectedGender = 'Macho'; // Predeterminado
  File? _selectedImage; // Imagen seleccionada desde el dispositivo
  String? _currentImageUrl; // URL actual de la imagen en Firebase

  @override
  void initState() {
    super.initState();
    // Inicializar controladores y valores predeterminados con datos existentes
    _nameController = TextEditingController(
      text: widget.petData['nombre'] ?? '',
    );
    _ageController = TextEditingController(text: widget.petData['edad'] ?? '');
    _weightController = TextEditingController(
      text: widget.petData['peso'] ?? '',
    );
    _traitsController = TextEditingController(
      text: widget.petData['rasgos'] ?? '',
    );
    _breedController = TextEditingController(
      text: widget.petData['raza'] ?? '',
    );
    _healthController = TextEditingController(
      text: widget.petData['salud'] ?? '',
    );
    _selectedGender =
        widget.petData['sexo'] ??
        'Macho'; // Asignar un valor por defecto si no está disponible
    _currentImageUrl =
        widget.petData['foto']; // Guardar la URL actual de la imagen
  }

  @override
  void dispose() {
    // Liberar los controladores al eliminar el widget
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _traitsController.dispose();
    _breedController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    try {
      String imageUrl = _currentImageUrl ?? '';
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance.ref().child(
          'mascotas/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('mascotas')
          .doc(widget.petId)
          .update({
            'nombre': _nameController.text,
            'edad': _ageController.text,
            'peso': _weightController.text,
            'rasgos': _traitsController.text,
            'raza': _breedController.text,
            'salud': _healthController.text,
            'sexo': _selectedGender,
            'foto': imageUrl,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información actualizada exitosamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la información')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Mascota',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(197, 233, 189, 148),
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 120, 114, 105), // Fondo gris claro
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Foto de la Mascota",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      _selectedImage != null
                          ? Image.file(
                            _selectedImage!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                          : (_currentImageUrl != null
                              ? Image.network(
                                _currentImageUrl!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.pets,
                                      size: 100,
                                      color: Colors.orange,
                                    ),
                              )
                              : const Icon(
                                Icons.pets,
                                size: 100,
                                color: Colors.orange,
                              )),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Cambiar Foto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 236, 217, 186),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Nombre", _nameController),
              _buildTextField("Edad (años)", _ageController, isNumeric: true),
              _buildTextField("Peso (kg)", _weightController, isNumeric: true),
              _buildTextField("Rasgos Físicos", _traitsController),
              _buildTextField("Raza", _breedController),
              _buildTextField("Estado de Salud", _healthController),
              _buildDropdownField("Sexo", ["Macho", "Hembra"]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar Cambios"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 236, 217, 186),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items:
            options.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value!;
          });
        },
      ),
    );
  }
}
