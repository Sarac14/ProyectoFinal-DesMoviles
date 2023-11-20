import 'package:flutter/material.dart';
import 'package:pokedex_proyecto_final/screens/home_screen.dart';
import 'package:pokedex_proyecto_final/widgets/splash_screen.dart';
import 'database/poke_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await PokeDatabase.instance.insertPokemonsFromApi();
  //await PokeDatabase.instance.printAllPokemons();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Muestra el splash screen al inicio.
      home: SplashScreen(),
      routes: {
        // Configura la pantalla principal.
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
