import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pokedex_proyecto_final/home_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var directory = await getApplicationDocumentsDirectory();
  var path = join(directory.path, 'pokemon_database.db');

  final database = await openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE pokemon(id INTEGER PRIMARY KEY, name TEXT, url TEXT)',
      );
      db.execute(
        'CREATE TABLE favorite_pokemon(id INTEGER PRIMARY KEY, pokemon_id INTEGER, FOREIGN KEY(pokemon_id) REFERENCES pokemon(id))',
      );
    },
    version: 2,
  );

  Future<void> insertPokemon(Pokemon pokemon) async {

    final db = await database;

    await db.insert(
      'pokemon',
      pokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Pokemon>> pokemonList() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('pokemon');

    return List.generate(maps.length, (i) {
      return Pokemon(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        url: maps[i]['url'] as String,
      );
    });
  }

  Future<void> updatePokemon(Pokemon pokemon) async {
    final db = await database;

    await db.update(
      'pokemon',
      pokemon.toMap(),
      where: 'id = ?',
      whereArgs: [pokemon.id],
    );
  }
  var url = Uri.parse('https://pokeapi.co/api/v2/pokemon/?limit=1300');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    List results = data['results'];

    // Insertar los datos en la base de datos
    for (var result in results) {
      Pokemon pokemon = Pokemon(
        id: results.indexOf(result),
        name: result['name'],
        url: result['url'],
      );
      await insertPokemon(pokemon);
    }
  } else {
    print('Failed to load data from API');
  }

  // Imprimir los primeros 10 pokemones en la consola
  List<Pokemon> pokemons = await pokemonList();
  print('Database path: $path');
  for (int i = 0; i < 1300 && i < pokemons.length; i++) {
    print(pokemons[i]);
  }
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

class Pokemon {
  final int id;
  final String name;
  final String url;

  const Pokemon({
    required this.id,
    required this.name,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }

  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $url}';
  }
}

