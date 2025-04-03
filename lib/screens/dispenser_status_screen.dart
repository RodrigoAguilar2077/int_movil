import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore

class DispenserStatusScreen extends StatelessWidget {
  const DispenserStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estado del Dispensador',
          style: TextStyle(
            fontFamily: 'Fjalla One', // Aquí se aplica la fuente
          ),
        ),
        backgroundColor: const Color.fromARGB(197, 233, 189, 148),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 120, 114, 105), // Fondo gris oscuro
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('dispensadores')
                      .doc(
                        'dispensador_id',
                      ) // Aquí el id del documento de Firestore
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error al cargar los datos"));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text("No se encontraron datos"));
                }

                // Obtén los valores del documento
                var data = snapshot.data!.data() as Map<String, dynamic>;

                // Accede al campo 'nivel' de cada dispensador
                double nivelComida = data['nivel_comida']?.toDouble() ?? 0.0;
                double nivelAgua = data['nivel_agua']?.toDouble() ?? 0.0;

                String comidaStatus = _getComidaStatus(nivelComida);
                String aguaStatus = _getAguaStatus(nivelAgua);

                return Row(
                  children: [
                    // Contenedor de comida
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.orange.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade200,
                            blurRadius: 5,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_dining,
                            size: 60,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Comida',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: nivelComida / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.orange.shade100,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.orange.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${nivelComida.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            comidaStatus,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  comidaStatus == "¡Rellenar ahora!"
                                      ? Colors.red
                                      : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contenedor de agua
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200,
                            blurRadius: 5,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_drink,
                            size: 60,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Agua',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: nivelAgua / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.blue.shade100,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${nivelAgua.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            aguaStatus,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  aguaStatus == "¡Rellenar ahora!"
                                      ? Colors.red
                                      : Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Función para obtener el estado de la comida
  String _getComidaStatus(double porcentaje) {
    if (porcentaje <= 10) {
      return "¡Rellenar ahora!";
    } else if (porcentaje <= 30) {
      return "Nivel bajo";
    } else if (porcentaje <= 70) {
      return "Nivel medio";
    } else {
      return "Nivel alto";
    }
  }

  // Función para obtener el estado del agua
  String _getAguaStatus(double porcentaje) {
    if (porcentaje <= 10) {
      return "¡Rellenar ahora!";
    } else if (porcentaje <= 30) {
      return "Nivel bajo";
    } else if (porcentaje <= 70) {
      return "Nivel medio";
    } else {
      return "Nivel alto";
    }
  }
}
