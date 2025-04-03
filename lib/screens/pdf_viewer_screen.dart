import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PDFViewerScreen extends StatefulWidget {
  final String firebasePath; // Ruta del PDF en Firebase Storage

  const PDFViewerScreen({super.key, required this.firebasePath});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath; // Ruta local donde se guardará el PDF
  bool isLoading = true; // Para manejar el estado de carga

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  // Cargar el archivo PDF desde Firebase Storage y guardarlo en el almacenamiento temporal
  Future<void> _loadPdf() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          widget.firebasePath.split('/').last; // Nombre del archivo
      final File file = File("${tempDir.path}/$fileName");

      // Verificar si el archivo ya está descargado
      if (!file.existsSync()) {
        // Descargar el archivo desde Firebase Storage
        await _downloadPdfFromFirebase(widget.firebasePath, file);
      }

      setState(() {
        localPath = file.path; // Actualiza la UI con la ruta del archivo
        isLoading = false; // Termina la carga
      });
    } catch (e) {
      print("Error al cargar el PDF: $e");
      _mostrarError();
    }
  }

  // Descargar el archivo PDF desde Firebase Storage
  Future<void> _downloadPdfFromFirebase(String firebasePath, File file) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(firebasePath);

      // Obtener el archivo como bytes
      final Uint8List? pdfBytes = await ref.getData();

      if (pdfBytes != null) {
        // Guardar el archivo localmente
        await file.writeAsBytes(pdfBytes, flush: true);
      } else {
        throw Exception("No se pudo descargar el archivo PDF.");
      }
    } catch (e) {
      print("Error al descargar el PDF desde Firebase: $e");
      _mostrarError();
    }
  }

  // Mostrar un mensaje de error al usuario
  void _mostrarError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error al cargar el archivo PDF")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visor PDF"),
        backgroundColor: Color.fromARGB(
          197,
          233,
          189,
          148,
        ), // Color personalizado para el AppBar
        elevation: 0, // Sin sombra
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Recargar el PDF
              setState(() {
                isLoading = true;
                localPath = null;
              });
              _loadPdf();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Cargando...
              : localPath == null
              ? const Center(child: Text("No se pudo cargar el archivo"))
              : Padding(
                padding: const EdgeInsets.all(
                  16.0,
                ), // Agregar espacio alrededor
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      16,
                    ), // Bordes redondeados
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // Sombra del contenedor
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      16,
                    ), // Bordes redondeados para el PDF
                    child: PDFView(
                      filePath: localPath!,
                      enableSwipe:
                          true, // Habilitar el deslizamiento entre páginas
                      swipeHorizontal: true, // Navegar de manera horizontal
                      autoSpacing: false,
                      pageFling:
                          true, // Hacer el deslizamiento de las páginas más fluido
                      onPageChanged: (int? page, int? total) {
                        // Cambios de página
                        print("Página actual: $page de $total");
                      },
                    ),
                  ),
                ),
              ),
    );
  }
}
