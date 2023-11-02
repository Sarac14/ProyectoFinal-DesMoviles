import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pokedex_proyecto_final/home_screen.dart';
import 'package:pokedex_proyecto_final/poke_database.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Llama a insertPokemonsFromApi para insertar los datos en la base de datos
  await PokeDatabase.instance.insertPokemonsFromApi();

  // Llama a printAllPokemons para imprimir los datos de la base de datos
  await PokeDatabase.instance.printAllPokemons();

  // Resto del código de tu aplicación Flutter
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


