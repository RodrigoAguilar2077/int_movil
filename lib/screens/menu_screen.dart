import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'perfil_screen.dart';
import 'register_schedule_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "¡Bienvenido a AutoPet UTT!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  final List<Widget> _screens = [
    HomeScreen(),
    PerfilScreen(),
    RegisterScheduleScreen(),
    CalendarScreen(),
    AjustesScreen(),
  ];

  void _onNavbarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AUTOPET UTT"),
        backgroundColor: const Color.fromARGB(255, 248, 238, 225),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[900], // Color de fondo gris oscuro
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onNavbarTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Horarios',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentContainerIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentContainerIndex = (_currentContainerIndex + 1) % 3;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/menu.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const SizedBox(height: 40),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _menuButton(
                  context,
                  'Estado del Dispensador',
                  Icons.percent,
                  Colors.red,
                  '/estadoDispensador',
                ),
                _menuButton(
                  context,
                  'Calendario',
                  Icons.calendar_today,
                  Colors.orange,
                  '/calendario',
                ),
                _menuButton(
                  context,
                  'Mi Mascota',
                  Icons.pets,
                  Colors.purple,
                  '/miMascota',
                ),
                _menuButton(
                  context,
                  'Registrar Mascota',
                  Icons.add_circle_outline,
                  Colors.blue,
                  '/register_pet',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          RecentInteractions(), // Nueva sección agregada aquí
          const SizedBox(height: 40),
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Container(
              key: ValueKey<int>(_currentContainerIndex),
              width: double.infinity,
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 248, 238, 225),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getContainerText(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Avisos Legales"),
                      content: SingleChildScrollView(
                        child: const Text(
                          "Términos y Condiciones\n\n"
                          "Última actualización: 31/03/25\n\n"
                          "Bienvenido a AutoPet Utt. Al utilizar nuestra aplicación, aceptas los siguientes términos y condiciones. Por favor, léelos detenidamente.\n\n"
                          "1. Uso de la aplicación\n"
                          "Esta aplicación está diseñada para gestionar y controlar los datos de tus mascotas y la función del dispensador. Nos esforzamos por garantizar su correcto funcionamiento, pero no garantizamos que esté libre de errores o interrupciones. No somos responsables por el uso indebido de la aplicación por parte de los usuarios.\n\n"
                          "2. Registro y seguridad de la cuenta\n"
                          "Al registrarte, aceptas proporcionar información veraz y mantener la confidencialidad de tu cuenta. No somos responsables del acceso no autorizado a tu cuenta por negligencia en la gestión de tus credenciales.\n\n"
                          "3. Privacidad y protección de datos\n"
                          "Cumplimos con la legislación vigente en materia de privacidad y protección de datos. Para más información, consulta nuestra Política de Privacidad.\n\n"
                          "4. Modificaciones y actualizaciones\n"
                          "Nos reservamos el derecho de modificar estos términos en cualquier momento. Se te notificará cualquier cambio importante para que puedas revisarlo antes de seguir usando la aplicación.\n\n"
                          "5. Limitación de responsabilidad\n"
                          "No nos hacemos responsables de cualquier daño directo o indirecto derivado del uso de nuestra aplicación.\n\n"
                          "6. Contacto\n"
                          "Si tienes preguntas sobre estos términos, puedes contactarnos a través de futetch2026@gmail.com.",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
              );
            },
            child: const Text(
              "Ver Avisos Legales",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  String _getContainerText() {
    switch (_currentContainerIndex) {
      case 0:
        return 'Información Nutricional: Proteínas como el pollo fortalecen músculos.';

      case 1:
        return 'Información Nutricional: Las grasas saludables mejoran la piel y el pelaje.';

      case 2:
        return 'Información Nutricional: Carbohidratos como el arroz brindan energía diaria.';

      case 3:
        return 'Sugerencias para el Cuidado: Paseos diarios reducen estrés y mejoran la salud.';

      case 4:
        return 'Sugerencias para el Cuidado: Baños regulares previenen problemas de piel.';

      case 5:
        return 'Sugerencias para el Cuidado: Un ambiente seguro mejora la calidad de vida.';

      case 6:
        return 'Recomendaciones de Salud: Vacunar a tiempo evita enfermedades graves.';

      case 7:
        return 'Recomendaciones de Salud: Revisiones veterinarias detectan problemas temprano.';

      case 8:
        return 'Recomendaciones de Salud: Síntomas como letargo pueden indicar enfermedades.';

      case 9:
        return 'Consejos de Entrenamiento: Refuerzo positivo mejora el aprendizaje.';

      case 10:
        return 'Consejos de Entrenamiento: La paciencia fortalece la confianza de tu mascota.';

      case 11:
        return 'Seguridad en el Hogar: Mantén objetos peligrosos fuera de su alcance.';

      case 12:
        return 'Seguridad en el Hogar: Asegura ventanas y balcones para evitar accidentes.';

      case 13:
        return 'Cuidado del Pelaje: Cepillado regular evita nudos y mejora la salud capilar.';

      case 14:
        return 'Cuidado del Pelaje: Alimentación balanceada mejora el brillo del pelaje.';

      default:
        return 'Contenido No Disponible';
    }
  }

  Widget _menuButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shadowColor: Colors.grey.withOpacity(0.5),
          elevation: 6,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentInteractions extends StatelessWidget {
  final List<Map<String, String>> interactions = [
    {
      "time": "Hoy, 10:45 AM",
      "event": "Comida dispensada",
      "details": "50g dispensados",
    },
    {
      "time": "Ayer, 6:30 PM",
      "event": "Agua recargada",
      "details": "Nivel de agua: 90%",
    },
    {
      "time": "Ayer, 12:00 PM",
      "event": "Comida dispensada",
      "details": "60g dispensados",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Últimas Interacciones",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ...interactions.map(
            (interaction) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.blueAccent),
                title: Text(interaction["event"] ?? ""),
                subtitle: Text(
                  "${interaction["time"]}\n${interaction["details"]}",
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
