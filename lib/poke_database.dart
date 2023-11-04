import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokeDatabase {
  static final PokeDatabase instance = PokeDatabase._();

  static Database? _database;

  PokeDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'poke.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE IF NOT EXISTS pokemon(id INTEGER PRIMARY KEY, name TEXT, url TEXT)',
        );
        db.execute(
          'CREATE TABLE IF NOT EXISTS favorite_pokemon(id INTEGER PRIMARY KEY, pokemon_id INTEGER, FOREIGN KEY(pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE)',
        );
      },
      version: 2,
    );
  }

  Future<int> insertPokemon(PokemonDB pokemon) async {
    final db = await database;
    return await db.insert(
      'pokemon',
      pokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPokemonsFromApi() async {
    var url = Uri.parse('https://pokeapi.co/api/v2/pokemon/?limit=1300');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List results = data['results'];

      // Insertar los datos en la base de datos
      for (var result in results) {
        PokemonDB pokemon = PokemonDB(
          id: results.indexOf(result) + 1,
          name: result['name'],
          url: result['url'],
        );
        await insertPokemon(pokemon);
      }
    } else {
      print('Failed to load data from API');
    }
  }

  Future<bool> toggleFavoritePokemon(int pokemonId) async {
    final db = await database;
    try {
      return await db.transaction((txn) async {
        // Check if the item already exists in the database
        final result = await txn.rawQuery(
          'SELECT * FROM favorite_pokemon WHERE pokemon_id = ?',
          [pokemonId],
        );

        // If the item exists, delete it from the database
        if (result.isNotEmpty) {
          await txn.rawDelete(
            'DELETE FROM favorite_pokemon WHERE pokemon_id = ?',
            [pokemonId],
          );
          return false;
        }
        // If the item does not exist, add it to the database
        else {
          await txn.rawInsert(
            'INSERT INTO favorite_pokemon(pokemon_id) VALUES(?)',
            [pokemonId],
          );
          return true;
        }
      });
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  Future<bool> isFavoritePokemon(int pokemonId) async {
    final db = await database;
    try {
      final result = await db.rawQuery(
        'SELECT * FROM favorite_pokemon WHERE pokemon_id = ?',
        [pokemonId],
      );

      if (result.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  /*Future<void> insertFavoritePokemon(int pokemonId) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.rawInsert(
          'INSERT OR REPLACE INTO favorite_pokemon(pokemon_id) VALUES(?)',
          [pokemonId],
        );
      });
    } catch (e) {
      print('Error occurred: $e');
    }
  }*/

  Future<int> deleteFavoritePokemon(int id) async {
    final db = await database;
    return await db.delete(
      'favorite_pokemon',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> checkIfFavorite(int pokemonId) async {
    final db = await database;
    final List<Map<String, dynamic>> favorites = await db.query(
      'favorite_pokemon',
      where: 'pokemon_id = ?',
      whereArgs: [pokemonId],
    );
    return favorites.isNotEmpty;
  }

  // Agrega este método a la clase PokeDatabase
  Future<void> printAllPokemons() async {
    final db = await database;
    final List<Map<String, dynamic>> pokemons = await db.query('pokemon');

    if (pokemons.isEmpty) {
      print('No pokemons found in the database.');
    } else {
      pokemons.forEach((pokemon) {
        print(
            'Pokemon - id: ${pokemon['id']}, name: ${pokemon['name']}, url: ${pokemon['url']}');
      });
    }
  }

  Future<void> printAllFavoritePokemons() async {
    final db = await database;
    final List<Map<String, dynamic>> favoritePokemons =
    await db.query('favorite_pokemon');

    if (favoritePokemons.isEmpty) {
      print('No favorite pokemons found in the database.');
    } else {
      favoritePokemons.forEach((favoritePokemon) {
        print(
            'Favorite Pokemon - id: ${favoritePokemon['id']}, pokemon_id: ${favoritePokemon['pokemon_id']}');
      });
    }
  }

  Future<List<PokemonDB>> getFavoritePokemons() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_pokemon',
      columns: ['pokemon_id'],
    );

    List<PokemonDB> favoritePokemons = [];

    for (var map in maps) {
      final pokemonId = map['pokemon_id'];
      final pokemonMap =
      await db.query('pokemon', where: 'id = ?', whereArgs: [pokemonId]);
      if (pokemonMap.isNotEmpty) {
        final pokemon = PokemonDB(
          id: pokemonMap[0]['id'] as int,
          name: pokemonMap[0]['name'] as String,
          url: pokemonMap[0]['url'] as String,
        );
        favoritePokemons.add(pokemon);
      }
    }
    return favoritePokemons;
  }

  Future<List<String>> getFavoritePokemonUrls() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_pokemon',
      columns: ['pokemon_id'],
    );

    List<String> favoritePokemonUrls = [];

    for (var map in maps) {
      final pokemonId = map['pokemon_id'];
      final pokemonMap = await db.query(
          'pokemon', where: 'id = ?', whereArgs: [pokemonId]);
      if (pokemonMap.isNotEmpty) {
        final url = pokemonMap[0]['url'] as String;
        favoritePokemonUrls.add(url);
      }
    }
    return favoritePokemonUrls;
  }

  Future<String> getPokemonUrlById(int id) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'pokemon',
      columns: ['url'],
      where: 'id = ?',
      whereArgs: [id],
    );

    return maps.first['url'];
  }
}

class PokemonDB {
  final int id;
  final String name;
  final String url;

  PokemonDB({required this.id, required this.name, required this.url});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }
}
