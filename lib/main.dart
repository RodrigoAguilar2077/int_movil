import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // Solicitar permiso para recibir notificaciones
    messaging.requestPermission();

    // Obtener el token FCM del dispositivo y guardarlo en Firestore
    messaging.getToken().then((token) {
      if (token != null) {
        saveFCMToken(token);
      }
    });

    // Escuchar notificaciones mientras la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido: ${message.notification?.title}');
      // Aquí podrías mostrar una notificación local, si deseas
    });
  }

  // Función para guardar el token FCM en Firestore
  void saveFCMToken(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'fcm_token': token, // Guarda el token en Firestore
          })
          .catchError((error) {
            print("Error al guardar token: $error");
          });
    }
  }

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
        '/miMascota': (context) => const MyPetScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/horarios': (context) => const RegisterScheduleScreen(),
        '/ajustes': (context) => const AjustesScreen(),
        '/calendario': (context) => const CalendarScreen(),
      },
    );
  }
}
