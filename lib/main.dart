import 'package:flutter/material.dart';
import 'package:pokedex_proyecto_final/screens/home_screen.dart';
import 'package:flutter/widgets.dart';
import 'database/poke_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Esta funcion se encarga de cargar los datos de la API en la base de datos
  //await PokeDatabase.instance.insertPokemonsFromApi();

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
