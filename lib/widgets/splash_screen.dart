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
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pokedex',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
            const SizedBox(height: 100),
            Image.asset(
              'images/pikachu-running.gif',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text('Iniciando...',style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            )),
          ],
        ),
      ),
    );
  }
}
