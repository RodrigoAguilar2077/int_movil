import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pdf_viewer_screen.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  _AjustesScreenState createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Configuración",
            style: TextStyle(fontFamily: 'Fjalla One'),
          ),
          backgroundColor: const Color.fromARGB(197, 233, 189, 148),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ajustes de la aplicación",
                style: TextStyle(
                  fontFamily: 'Fjalla One',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _OpcionSwitch(
                icono: Icons.notifications,
                titulo: "Notificaciones",
                subtitulo: "Configura las notificaciones de la app",
              ),
              const SizedBox(height: 10),
              _opcionConfiguracion(
                icono: Icons.book,
                titulo: "Manuales",
                subtitulo: "Ver manuales de la aplicación",
                onTap: () {
                  _mostrarDialogoManuales(context);
                },
              ),
              const SizedBox(height: 10),
              _opcionConfiguracion(
                icono: Icons.brightness_6,
                titulo: "Modo Oscuro",
                subtitulo: _isDarkMode ? "Activado" : "Desactivado",
                onTap: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                    _saveThemePreference(_isDarkMode);
                  });
                },
              ),
              const SizedBox(height: 20),
              // Agregar Switch para el modo oscuro
              SwitchListTile(
                title: const Text('Modo Oscuro'),
                value: _isDarkMode,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkMode = value;
                    _saveThemePreference(_isDarkMode);
                  });
                },
                activeColor: const Color.fromARGB(
                  197,
                  228,
                  149,
                  74,
                ), // Color del switch activo
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _opcionConfiguracion({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icono, color: Color.fromARGB(197, 228, 149, 74)),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _mostrarDialogoManuales(BuildContext context) async {
    List<Map<String, String>> manuales = [
      {
        "titulo": "Manual de Instalación IoT",
        "ruta": "assets/pdfs/Manual_de_Instalacion_de_IoT.pdf",
      },
      {
        "titulo": "Manual de Uso de la App",
        "ruta": "assets/pdfs/Manual_de_Uso_de_la_Aplicacion.pdf",
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Manuales de la Aplicación"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                manuales
                    .map(
                      (manual) => _itemManual(
                        context,
                        manual["titulo"]!,
                        manual["ruta"]!,
                      ),
                    )
                    .toList(),
          ),
          actions: [
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _itemManual(BuildContext context, String titulo, String assetPath) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
      title: Text(titulo),
      onTap: () {
        Navigator.pop(context);
        _abrirPDF(context, assetPath);
      },
    );
  }

  void _abrirPDF(BuildContext context, String assetPath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String? filePath = await _copiarPDFDesdeAssets(assetPath);
    Navigator.pop(context);

    if (filePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(firebasePath: filePath),
        ),
      );
    } else {
      _mostrarError(context);
    }
  }

  Future<String?> _copiarPDFDesdeAssets(String assetPath) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/${assetPath.split('/').last}';
      final File file = File(filePath);

      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);

      return filePath;
    } catch (e) {
      print("Error cargando PDF: $e");
      return null;
    }
  }

  void _mostrarError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: const Text(
            "No se pudo cargar el archivo PDF. Verifica que el archivo existe.",
          ),
          actions: [
            TextButton(
              child: const Text("Aceptar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

// Componente separado para el Switch (notificaciones)
class _OpcionSwitch extends StatefulWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;

  const _OpcionSwitch({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    Key? key,
  }) : super(key: key);

  @override
  _OpcionSwitchState createState() => _OpcionSwitchState();
}

class _OpcionSwitchState extends State<_OpcionSwitch> {
  bool _switchValue = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(
          widget.icono,
          color: const Color.fromARGB(197, 228, 149, 74), // Color unificado
        ),
        title: Text(
          widget.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.subtitulo),
        trailing: Switch(
          value: _switchValue,
          activeColor: const Color.fromARGB(
            197,
            228,
            149,
            74,
          ), // Color del switch activo
          onChanged: (value) {
            setState(() {
              _switchValue = value;
            });
          },
        ),
      ),
    );
  }
}
