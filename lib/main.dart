import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:int_movil/screens/menu_screen.dart';
import 'package:int_movil/screens/login_screen.dart';
import 'package:int_movil/screens/dispenser_status_screen.dart';
import 'package:int_movil/screens/my_pet_screen.dart';
import 'package:int_movil/screens/register_diet_screen.dart';
import 'package:int_movil/screens/register_pet_screen.dart';
import 'package:int_movil/screens/perfil_screen.dart';
import 'package:int_movil/screens/register_schedule_screen.dart';
import 'package:int_movil/screens/settings_screen.dart';
import 'package:int_movil/screens/calendar_screen.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Descomentado
import 'dart:async';
import 'dart:typed_data'; // Para manejar los bytes del archivo PDF
import 'package:flutter/services.dart'; // Para cargar el archivo desde los assets
import 'package:path_provider/path_provider.dart'; // Para manejar el directorio local

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase antes de correr la app

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoPet UTT',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Comienza desde la pantalla de login
      routes: {
        '/login': (context) => const LoginScreen(),
        '/menu': (context) => const MenuScreen(),
        '/register_pet': (context) => const RegistrarMascotaScreen(),
        '/registrarDieta': (context) => const RegisterDietScreen(),
        '/estadoDispensador': (context) => const DispenserStatusScreen(),
        '/calendario': (context) => const CalendarScreen(),
        '/miMascota': (context) => const MyPetScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/horarios': (context) => const RegisterScheduleScreen(),
        '/ajustes': (context) => const AjustesScreen(),
        '/pdfList': (context) => const PDFListScreen(), // Lista de PDFs
      },
    );
  }
}

class PDFListScreen extends StatefulWidget {
  const PDFListScreen({Key? key}) : super(key: key);

  @override
  _PDFListScreenState createState() => _PDFListScreenState();
}

class _PDFListScreenState extends State<PDFListScreen> {
  final List<Map<String, String>> pdfList = [
    {
      "name": "Manual de Instalación de IoT",
      "file": "assets/pdfs/Manual_de_Instalacion_de_IoT.pdf",
    },
    {
      "name": "Manual de Uso de la Aplicación",
      "file": "assets/pdfs/Manual_de_Uso_de_la_Aplicacion.pdf",
    },
  ];

  void viewPDF(String assetPath) async {
    // Obtener el directorio donde guardar el PDF localmente
    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDocDir.path}/${assetPath.split('/').last}';

    // Verificar si el archivo ya existe, si no, copiarlo desde los assets
    final fileExists = await File(filePath).exists();
    if (!fileExists) {
      final byteData = await rootBundle.load(assetPath);
      final buffer = byteData.buffer.asUint8List();
      await File(filePath).writeAsBytes(buffer);
    }

    // Abrir el archivo PDF desde la ruta local
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(filePath: filePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de PDFs")),
      body: ListView.builder(
        itemCount: pdfList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(pdfList[index]['name']!),
            trailing: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => viewPDF(pdfList[index]['file']!),
            ),
          );
        },
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  const PDFViewerScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visor de PDF"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: PDFView(
        filePath: filePath, // Pasamos la ruta local del archivo PDF
        onViewCreated: (PDFViewController pdfViewController) {
          pdfViewController.setPage(0); // Establece la página inicial
        },
      ),
    );
  }
}
