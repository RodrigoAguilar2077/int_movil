import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_pet_screen.dart'; // Importar la pantalla de edición
import 'view_diets_screen.dart'; // Pantalla para ver dietas
import 'add_edit_diet_screen.dart'; // Pantalla para agregar o editar dieta

class MyPetScreen extends StatefulWidget {
  const MyPetScreen({super.key});

  @override
  _MyPetScreenState createState() => _MyPetScreenState();
}

class _MyPetScreenState extends State<MyPetScreen> {
  Future<List<DocumentSnapshot>> _getPetsData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('mascotas').get();
    return querySnapshot.docs;
  }

  late Future<List<DocumentSnapshot>> petsFuture;

  @override
  void initState() {
    super.initState();
    petsFuture = _getPetsData(); // Inicializamos el futuro al inicio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Mascotas',
          style: TextStyle(
            fontFamily: 'Fjalla One', // Aquí se aplica la fuente
          ),
        ),
        backgroundColor: Color.fromARGB(197, 233, 189, 148),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 120, 114, 105), // Fondo gris oscuro
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: petsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Error al cargar mascotas.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No hay mascotas registradas',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            List<DocumentSnapshot> pets = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Mostrar 2 tarjetas por fila
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9, // Proporción para las tarjetas
                ),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  var petData = pets[index].data() as Map<String, dynamic>;
                  var petId = pets[index].id; // Obtener el ID del documento
                  return GestureDetector(
                    onTap: () => _showPetDetails(context, petData, petId),
                    child: _buildPetCard(petData),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> petData) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPetImage(petData['foto'], size: 100),
            const SizedBox(height: 10),
            Text(
              petData['nombre'] ?? 'Sin nombre',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              petData['raza'] ?? 'Raza desconocida',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            Text(
              '${petData['edad'] ?? 'N/A'} años',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage(String? imageUrl, {double size = 150}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          imageUrl != null
              ? Image.network(
                imageUrl,
                height: size,
                width: size,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.pets,
                      size: 100,
                      color: Color.fromARGB(197, 233, 189, 148),
                    ),
              )
              : const Icon(
                Icons.pets,
                size: 100,
                color: Color.fromARGB(255, 217, 185, 136),
              ),
    );
  }

  void _showPetDetails(
    BuildContext context,
    Map<String, dynamic> petData,
    String petId,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Fondo semi-transparente
      builder: (context) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // Hace el fondo del diálogo transparente
          elevation: 0, // Elimina la sombra del diálogo
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // Fondo del contenido del diálogo
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPetImage(petData['foto'], size: 200), // Foto más grande
                const SizedBox(height: 20),
                Text(
                  petData['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  petData['raza'] ?? 'Raza desconocida',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  '${petData['edad'] ?? 'N/A'} años',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _editPetInfo(context, petData, petId);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Información'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 236, 217, 186),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _viewPetDiets(context, petData, petId);
                  },
                  icon: const Icon(Icons.food_bank),
                  label: const Text('Ver Dietas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 236, 217, 186),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _editPetDiet(context, petId);
                  },
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Agregar/Editar Dieta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 236, 217, 186),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Eliminar la mascota de Firestore
                    await FirebaseFirestore.instance
                        .collection('mascotas')
                        .doc(petId)
                        .delete();

                    // Cerrar el diálogo
                    Navigator.pop(context);

                    // Mostrar el mensaje de confirmación con un SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mascota eliminada correctamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Recargar los datos
                    setState(() {
                      petsFuture = _getPetsData();
                    });
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar Mascota'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Color rojo para el botón de eliminar
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editPetInfo(
    BuildContext context,
    Map<String, dynamic> petData,
    String petId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditPetScreen(
              petData: petData, // Datos de la mascota
              petId: petId, // ID del documento en Firestore
            ),
      ),
    ).then((_) {
      // Recargar los datos después de regresar de la pantalla de edición
      setState(() {
        petsFuture = _getPetsData();
      });
    });
  }

  void _viewPetDiets(
    BuildContext context,
    Map<String, dynamic> petData,
    String petId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ViewDietsScreen(
              petId: petId,
              petName:
                  petData['nombre'] ?? 'Sin nombre', // Proporciona el nombre
            ),
      ),
    );
  }

  void _editPetDiet(BuildContext context, String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditDietScreen(petId: petId)),
    );
  }
}
