import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isSigningIn = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/menu');
      }
    } catch (e) {
      print("Error al iniciar sesión: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al iniciar sesión',
              style: GoogleFonts.fjallaOne(),
            ),
          ),
        );
      }
    }

    setState(() => _isSigningIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(0), // Asegura que no se voltee
                child: Image.asset(
                  'assets/images/login_final.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter, // Evita inversiones
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "AUTOPET UTT",
                    style: GoogleFonts.fjallaOne(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 15),
                  Text(
                    "Inicia sesión con Google para continuar",
                    style: GoogleFonts.fjallaOne(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  _isSigningIn
                      ? const CircularProgressIndicator(color: Colors.white)
                      : GestureDetector(
                        onTap: _signInWithGoogle,
                        child: Container(
                          width: 250,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/google_logo.png', height: 24),
                              const SizedBox(width: 10),
                              Text(
                                "Continuar con Google",
                                style: GoogleFonts.fjallaOne(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              "FutureTech - Todos los derechos reservados",
              textAlign: TextAlign.center,
              style: GoogleFonts.fjallaOne(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
