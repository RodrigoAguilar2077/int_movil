import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterDietScreen extends StatefulWidget {
  const RegisterDietScreen({super.key});

  @override
  State<RegisterDietScreen> createState() => _RegisterDietScreenState();
}

class _RegisterDietScreenState extends State<RegisterDietScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController();
  final _restrictionsController = TextEditingController();
  final _notesController = TextEditingController();

  // Aquí puedes asignar directamente un valor para prueba
  String? _selectedPet = "somePetId"; // ID de una mascota específica

  // Método para registrar la dieta
  Future<void> _registerDiet() async {
    if (_formKey.currentState!.validate() && _selectedPet != null) {
      try {
        double quantity = double.tryParse(_quantityController.text) ?? 0.0;
        if (quantity <= 0) {
          showCupertinoDialog(
            context: context,
            builder:
                (context) => CupertinoAlertDialog(
                  title: const Text('Error'),
                  content: const Text(
                    'La cantidad debe ser un número mayor que 0.',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
          );
          return;
        }

        // Registrar en Firestore
        await FirebaseFirestore.instance.collection('dietas').add({
          'mascotaid': _selectedPet,
          'tipo': _typeController.text,
          'marca': _brandController.text,
          'cantidad': quantity,
          'restricciones': _restrictionsController.text,
          'notas': _notesController.text,
        });

        // Mostrar mensaje de éxito
        showCupertinoDialog(
          context: context,
          builder:
              (context) => CupertinoAlertDialog(
                title: const Text('Dieta Registrada'),
                content: const Text('La dieta se ha registrado correctamente.'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );

        // Limpiar campos
        setState(() {
          _selectedPet = null;
          _typeController.clear();
          _brandController.clear();
          _quantityController.clear();
          _restrictionsController.clear();
          _notesController.clear();
        });
      } catch (e) {
        print("Error al registrar la dieta: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Registrar Dieta'),
      ),
      child: SingleChildScrollView(
        // Hacemos la pantalla desplazable
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo para seleccionar mascota
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CupertinoTextField(
                  readOnly: true,
                  placeholder:
                      _selectedPet == null
                          ? 'Selecciona una mascota'
                          : 'Mascota seleccionada',
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    // Aquí iría la lógica para seleccionar mascota, si se reactivara
                  },
                ),
              ),
              _buildTextField(_typeController, 'Tipo de comida'),
              _buildTextField(_brandController, 'Marca de la comida'),
              _buildTextField(_quantityController, 'Cantidad (gramos)'),
              _buildTextField(
                _restrictionsController,
                'Restricciones alimenticias',
              ),
              _buildTextField(_notesController, 'Notas adicionales'),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: _registerDiet,
                child: const Text('Registrar Dieta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para construir un campo de texto
  Widget _buildTextField(TextEditingController controller, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
