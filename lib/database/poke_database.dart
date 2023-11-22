import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Entities/Pokemon.dart';


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
          'CREATE TABLE IF NOT EXISTS pokemon(id INTEGER PRIMARY KEY, name TEXT, url TEXT, type TEXT, image TEXT)',
        );
        db.execute(
          'CREATE TABLE IF NOT EXISTS favorite_pokemon(id INTEGER PRIMARY KEY, pokemon_id INTEGER, FOREIGN KEY(pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE)',
        );
      },
      version: 1,
    );
  }

  void getDatabaseLocation() async {
    var databasesPath = await getDatabasesPath();
    print("Ruta de la base de datos: $databasesPath");
  }

  // Inserta un Pokémon en la base de datos.
  Future<int> insertPokemon(PokemonDB pokemon) async {
    final db = await database;
    return await db.insert(
      'pokemon',
      pokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAllPokemon() async {
    final db = await instance.database;
    await db.delete('pokemon');
  }

  Future<List<PokemonDB>> getPokemonsWithLimitAndOffset(
      int limit, int offset) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM pokemon LIMIT ? OFFSET ?',
      [limit, offset],
    );

    List<PokemonDB> pokemons = [];

    for (var result in results) {
      PokemonDB pokemon = PokemonDB(
        id: result['id'] as int,
        name: result['name'] as String,
        url: result['url'] as String,
        type: result['type'] as String,
        image: result['image'] as String,
      );
      pokemons.add(pokemon);
    }
    return pokemons;
  }

  Future<List<String>> getAllPokemonTypes() async {
    final db = await database;

    final List<Map<String, dynamic>> types = await db.rawQuery('''
    SELECT DISTINCT type FROM pokemon
  ''');

    final uniqueTypes = types.map((type) => type['type'].toString()).toList();

    // Agregar la opción "Todos" a la lista
    uniqueTypes.insert(0, 'all');

    return uniqueTypes;
  }
  Future<List<PokemonDB>> getPokemonsByTypeAndLimitAndOffset(String type, int limit, int offset) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM pokemon WHERE type = ? LIMIT ? OFFSET ?',
      [type, limit, offset],
    );

    List<PokemonDB> pokemons = [];

    for (var result in results) {
      PokemonDB pokemon = PokemonDB(
        id: result['id'] as int,
        name: result['name'] as String,
        url: result['url'] as String,
        type: result['type'] as String,
        image: result['image'] as String,
      );
      pokemons.add(pokemon);
    }
    return pokemons;
  }

  Future<void> checkAndAddMissingPokemon() async {
    var url = Uri.parse('https://pokeapi.co/api/v2/pokemon/?limit=1300');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List results = data['results'];

      for (var result in results) {
        var pokemonUrl = result['url'];
        var pokemonResponse = await http.get(Uri.parse(pokemonUrl));
        if (pokemonResponse.statusCode == 200) {
          var pokemonData = jsonDecode(pokemonResponse.body);
          var id = pokemonData['id'] as int;
          var existingPokemon = await getPokemonById(id);
          if (existingPokemon == null) {
            var types = pokemonData['types'];
            var typeName = types[0]['type']['name'] as String;
            var imageUrl = pokemonData['sprites']['other']['official-artwork']
                ['front_default'] as String;
            imageUrl ??= pokemonData['sprites']['front_default'] as String;
            print("id: $id");
            PokemonDB pokemon = PokemonDB(
              id: id,
              name: result['name'],
              url: result['url'],
              type: typeName,
              image: imageUrl,
            );
            await insertPokemon(pokemon);
          }
        } else {
          print('Failed to load data for ${result['name']} from API');
        }
      }
    } else {
      print('Failed to load data from API');
    }
  }

  Future<PokemonDB?> getPokemonById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'pokemon',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    } else {
      return PokemonDB(
        id: results[0]['id'] as int,
        name: results[0]['name'] as String,
        url: results[0]['url'] as String,
        type: results[0]['type'] as String,
        image: results[0]['image'] as String,
      );
    }
  }

  Future<void> insertPokemonsFromApi() async {
    var url = Uri.parse('https://pokeapi.co/api/v2/pokemon/?limit=1294');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List results = data['results'];

      // Insertar los datos en la base de datos
      for (var result in results) {
        var pokemonUrl = result['url'];
        var pokemonResponse = await http.get(Uri.parse(pokemonUrl));
        if (pokemonResponse.statusCode == 200) {
          var pokemonData = jsonDecode(pokemonResponse.body);
          var types = pokemonData['types'];
          var typeName = types[0]['type']['name'];
          var imageUrl = pokemonData['sprites']['other']['official-artwork']
              ['front_default'] as String?;
          if (imageUrl == null) {
            imageUrl = pokemonData['sprites']['front_default'] as String?;
          }

          PokemonDB pokemon = PokemonDB(
            id: results.indexOf(result) + 1,
            name: result['name'],
            url: result['url'],
            type: typeName,
            image: imageUrl ?? '',
          );
          await insertPokemon(pokemon);
        } else {
          print('Failed to load data for ${result['name']} from API');
        }
      }
    } else {
      print('Failed to load data from API');
    }
  }

  // Marca o desmarca un Pokémon como favorito en la base de datos.
  Future<bool> toggleFavoritePokemon(int pokemonId) async {
    final db = await database;
    try {
      return await db.transaction((txn) async {
        // verifica si ya existe en la base de datos
        final result = await txn.rawQuery(
          'SELECT * FROM favorite_pokemon WHERE pokemon_id = ?',
          [pokemonId],
        );

        // si existe, lo elimina de la base de datos
        if (result.isNotEmpty) {
          await txn.rawDelete(
            'DELETE FROM favorite_pokemon WHERE pokemon_id = ?',
            [pokemonId],
          );
          return false;
        }
        // si no existe, se agrega a la base de datos
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

  //Imprime todos los pokemones guardados en la base de datos en la consola
  Future<void> printAllPokemons() async {
    final db = await database;
    final List<Map<String, dynamic>> pokemons = await db.query('pokemon');

    if (pokemons.isEmpty) {
      print('No pokemons found in the database.');
    } else {
      pokemons.forEach((pokemon) {
        print(
            'Pokemon - id: ${pokemon['id']}, name: ${pokemon['name']}, url: ${pokemon['url']}, type: ${pokemon['type']}, image: ${pokemon['image']}');
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
            type: pokemonMap[0]['type'] as String,
            image: pokemonMap[0]['image'] as String);
        favoritePokemons.add(pokemon);
      }
    }
    return favoritePokemons;
  }

  Future<List<PokemonCard>> searchPokemons(String query) async {
    final db = await database;

    // Intenta convertir la consulta a un número (ID del Pokémon).
    int? pokemonId = int.tryParse(query);

    if (pokemonId != null) {
      // Si la conversión fue exitosa, busca el Pokémon por ID.
      List<Map<String, dynamic>> results = await db.rawQuery(
        'SELECT * FROM pokemon WHERE id = ?',
        [pokemonId],
      );

      List<PokemonCard> pokemons = [];

      for (var result in results) {
        PokemonDB pokemon = PokemonDB(
          id: result['id'] as int,
          name: result['name'] as String,
          url: result['url'] as String,
          type: result['type'] as String,
          image: result['image'] as String,
        );
        PokemonCard pokemonCard = PokemonCard.fromPokemonDB(pokemon);
        pokemons.add(pokemonCard);
      }
      return pokemons;
    } else {
      // Si la conversión falla, busca por nombre.
      List<Map<String, dynamic>> results = await db.rawQuery(
        'SELECT * FROM pokemon WHERE name LIKE ?',
        ['$query%'],
      );

      List<PokemonCard> pokemons = [];

      for (var result in results) {
        PokemonDB pokemon = PokemonDB(
          id: result['id'] as int,
          name: result['name'] as String,
          url: result['url'] as String,
          type: result['type'] as String,
          image: result['image'] as String,
        );
        PokemonCard pokemonCard = PokemonCard.fromPokemonDB(pokemon);
        pokemons.add(pokemonCard);
      }
      return pokemons;
    }
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
      final pokemonMap =
          await db.query('pokemon', where: 'id = ?', whereArgs: [pokemonId]);
      if (pokemonMap.isNotEmpty) {
        final url = pokemonMap[0]['url'] as String;
        favoritePokemonUrls.add(url);
      }
    }
    return favoritePokemonUrls;
  }
}

class PokemonDB {
  final int id;
  final String name;
  final String url;
  final String type;
  final String image;

  PokemonDB({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'image': image,
    };
  }
}
