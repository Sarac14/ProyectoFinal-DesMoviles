import 'package:flutter/material.dart';
import 'package:pokedex_proyecto_final/home_screen.dart';
import 'package:pokedex_proyecto_final/poke_database.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PokeDatabase.instance.insertPokemonsFromApi();

  await PokeDatabase.instance.printAllPokemons();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //const Pokedex({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
