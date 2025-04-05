import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: RegistrarMascotaScreen(),
    );
  }
}

class RegistrarMascotaScreen extends StatefulWidget {
  const RegistrarMascotaScreen({super.key});

  @override
  _RegistrarMascotaScreenState createState() => _RegistrarMascotaScreenState();
}

class _RegistrarMascotaScreenState extends State<RegistrarMascotaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _rasgosController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _saludController = TextEditingController();

  String _sexoSeleccionado = 'Macho';
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.storage, Permission.camera].request();

    if (statuses[Permission.storage]!.isGranted ||
        statuses[Permission.camera]!.isGranted) {
      return true;
    } else if (statuses[Permission.storage]!.isPermanentlyDenied ||
        statuses[Permission.camera]!.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }

  Future<void> _pickImage() async {
    bool hasPermission = await _requestPermissions();

    if (hasPermission) {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      _mostrarAlerta('Permiso denegado. Ve a configuración para habilitarlo.');
    }
  }

  void _registrarMascota() async {
    if (_nombreController.text.isEmpty || _edadController.text.isEmpty) {
      _mostrarAlerta('Por favor, completa todos los campos.');
      return;
    }

    try {
      String imageUrl = "";
      if (_image != null) {
        final ref = FirebaseStorage.instance.ref().child(
          'mascotas/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('mascotas').add({
        'nombre': _nombreController.text,
        'edad': _edadController.text,
        'peso': _pesoController.text,
        'rasgos': _rasgosController.text,
        'raza': _razaController.text,
        'salud': _saludController.text,
        'sexo': _sexoSeleccionado,
        'foto': imageUrl,
      });

      _mostrarModalExito();
    } catch (e) {
      _mostrarAlerta('Error al registrar la mascota.');
    }
  }

  void _mostrarModalExito() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("✅ Éxito"),
            content: const Text("Mascota registrada con éxito."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  _limpiarCampos();
                },
              ),
            ],
          ),
    );
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Aviso"),
            content: Text(mensaje),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _limpiarCampos() {
    setState(() {
      _nombreController.clear();
      _edadController.clear();
      _pesoController.clear();
      _rasgosController.clear();
      _razaController.clear();
      _saludController.clear();
      _sexoSeleccionado = 'Macho';
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registrar Mascota 🐾",
          style: TextStyle(
            fontFamily: 'Fjalla One', // Aquí se aplica la fuente
          ),
        ),
        backgroundColor: Color.fromARGB(197, 233, 189, 148),
      ),
      body: Container(
        color: Color.fromARGB(255, 120, 114, 105), // Color de fondo gris
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildImagePicker(),
              const SizedBox(height: 40),
              _buildTextField("Nombre", _nombreController),
              _buildTextField("Edad (años)", _edadController, isNumeric: true),
              _buildTextField("Peso (kg)", _pesoController, isNumeric: true),
              _buildTextField("Rasgos Físicos", _rasgosController),
              _buildTextField("Raza", _razaController),
              _buildTextField("Estado de Salud", _saludController),
              _buildDropdownField("Sexo", ["Macho", "Hembra"]),
              const SizedBox(height: 55),
              ElevatedButton(
                onPressed: _registrarMascota,
                child: const Text("Registrar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(
                    255,
                    236,
                    217,
                    186,
                  ), // Color del botón
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
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.white, // Fondo blanco para los TextField
          filled: true, // Habilita el fondo del campo de texto
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Esquinas redondeadas
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ), // Borde azul cuando el campo está enfocado
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> opciones) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _sexoSeleccionado,
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.white, // Fondo blanco para el Dropdown
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Esquinas redondeadas
          ),
        ),
        onChanged: (value) {
          setState(() {
            _sexoSeleccionado = value!;
          });
        },
        items:
            opciones.map((String e) {
              return DropdownMenuItem<String>(value: e, child: Text(e));
            }).toList(),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey[200],
        ),
        child:
            _image == null
                ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
      ),
    );
  }
}
