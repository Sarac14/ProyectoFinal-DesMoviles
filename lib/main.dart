import 'package:flutter/material.dart';
import 'package:pokedex_proyecto_final/screens/home_screen.dart';
import 'package:pokedex_proyecto_final/widgets/splash_screen.dart';
import 'database/poke_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await PokeDatabase.instance.insertPokemonsFromApi();
  //await PokeDatabase.instance.printAllPokemons();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
