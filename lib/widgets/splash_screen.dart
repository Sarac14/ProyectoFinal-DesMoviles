import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Comienza en la parte superior
            end: Alignment.bottomCenter,
            colors: [
              Colors.red, // Color rojo en la mitad izquierda
              Colors.white, // Color blanco en la mitad derecha
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row( // Usamos un Row para alinear horizontalmente la imagen y el texto
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/logo_pokedex.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(width: 1), // Espacio entre la imagen y el texto
                  const Text(
                    'Pokedex',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
              Image.asset(
                'images/pikachu-running.gif',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              const Text(
                'Iniciando...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
