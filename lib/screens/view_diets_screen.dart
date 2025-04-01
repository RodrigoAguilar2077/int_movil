import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDietsScreen extends StatelessWidget {
  final String petId;
  final String petName; // Nombre de la mascota

  const ViewDietsScreen({Key? key, required this.petId, required this.petName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dietas de $petName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(197, 233, 189, 148),
        elevation: 4,
        shadowColor: Colors.orange.shade200,
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 120, 114, 105), // Fondo gris claro
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('dietas')
                  .where('mascotaid', isEqualTo: petId)
                  .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No hay dietas registradas.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 247, 246, 246),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            var diets = snapshot.data!.docs;

            return ListView.builder(
              itemCount: diets.length,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemBuilder: (context, index) {
                var dietData = diets[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  shadowColor: Colors.orange.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'DIETA DE ${petName.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Divider(
                          color: Colors.orange,
                          thickness: 1,
                          height: 20,
                        ),
                        Text(
                          'Tipo: ${dietData['tipo'] ?? 'Sin tipo de comida'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Marca: ${dietData['marca'] ?? 'No especificada'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Cantidad: ${dietData['cantidad']?.toString() ?? 'N/A'} gramos',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Restricciones: ${dietData['restricciones'] ?? 'No aplican'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Notas: ${dietData['notas'] ?? 'Sin notas'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
