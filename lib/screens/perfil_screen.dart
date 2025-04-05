import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:int_movil/theme_provider.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? Colors.black87 : const Color(0xFFFAF7F2),
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor:
            themeProvider.isDarkMode
                ? Colors.grey[900]
                : const Color(0xFFE74C3C),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Imagen de perfil
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                child:
                    user?.photoURL == null
                        ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        )
                        : null,
                backgroundColor: const Color(
                  0xFF4CAF50,
                ), // Fondo verde si no hay foto
              ),
              const SizedBox(height: 20),

              // 🔹 Nombre de usuario
              Text(
                user?.displayName ?? 'Usuario sin nombre',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // 🔹 Correo electrónico
              Text(
                user?.email ?? 'Correo no disponible',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      themeProvider.isDarkMode ? Colors.white70 : Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 Botón de cerrar sesión
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text("Cerrar sesión"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C), // Rojo más suave
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5, // Sombra sutil para el botón
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
