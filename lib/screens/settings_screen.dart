import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  void _cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
      context,
      '/login',
    ); // Redirige a la pantalla de login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _cerrarSesion(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
          child: const Text(
            "Cerrar Sesión",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
