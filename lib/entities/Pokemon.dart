import 'dart:convert';

import '../database/poke_database.dart';
import 'Evolution.dart';
import 'Move.dart';
import 'Stats.dart';
import 'package:http/http.dart' as http;


class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  late final List<Ability> abilities;
  final String category;
  final String description;
  final Stats stats;
  List<Move> moves;
  late final List<Evolution> evolutionChain;


  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.category,
    required this.description,
    required this.stats,



  }): moves = [];

  void setAbilities(List<Ability> newAbilities) {
    abilities = newAbilities;
  }

  List<Ability> getAbilities() {
    return abilities;
  }

  factory Pokemon.fromJson(Map<String, dynamic> json, List<Ability> listAbilities, String category, String description, Stats stats, List moves) {
    var typeList = (json['types'] as List)
        .map((typeData) {
      if (typeData is Map<String, dynamic>) {
        return typeData['type']['name'] as String;
      } else if (typeData is String) {
        return typeData;
      } else {
        return 'Tipo Desconocido';
      }
    }).toList();

    var stats = Stats.fromJson(json['stats']);


    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] as String,
      types: typeList,
      height: (json['height']) as int,
      weight: (json['weight']) as int,
      abilities: listAbilities,
      category: category,
      description: description,
      stats: stats,
     // moves: [],
    );
  }

  Future<void> loadEvolutionChain() async {
    try {
      // Paso 1: Obtener la URL de la especie del Pokémon
      var pokemonResponse = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));
      var pokemonData = json.decode(pokemonResponse.body);
      var speciesUrl = pokemonData['species']['url'];

      // Paso 2: Obtener la URL de la cadena de evolución
      var speciesResponse = await http.get(Uri.parse(speciesUrl));
      var speciesData = json.decode(speciesResponse.body);
      var evolutionChainUrl = speciesData['evolution_chain']['url'];

      // Paso 3: Obtener la cadena de evolución
      var evolutionResponse = await http.get(Uri.parse(evolutionChainUrl));
      var evolutionData = json.decode(evolutionResponse.body);
      var evolutionChainData = EvolutionChain.fromJson(evolutionData);

      // Transformar la cadena de evolución en una lista de objetos Evolution
      this.evolutionChain = _processEvolutionChain(evolutionChainData.chain);

    } catch (e) {
      print("Error loading evolution chain: $e");
    }
  }

  // Método auxiliar para procesar la cadena de evolución
  List<Evolution> _processEvolutionChain(Chain chain) {
    List<Evolution> evolutions = [];
    _addEvolutions(chain, evolutions);
    return evolutions;
  }

  // Método recursivo para agregar evoluciones a la lista
  void _addEvolutions(Chain chain, List<Evolution> evolutions) {
    var evolution = Evolution.fromChain(chain);
    evolutions.add(evolution);

    for (var nextChain in chain.evolvesTo) {
      _addEvolutions(nextChain, evolutions);
    }
  }

  Future<void> loadMoves(String learnMethod) async {
    try {
      var pokemonUrl = "https://pokeapi.co/api/v2/pokemon/$name";
      var response = await http.get(Uri.parse(pokemonUrl));
      var data = json.decode(response.body);

      var movesData = data['moves'] as List;
      var moveFetchTasks = <Future>[];

      for (var moveData in movesData) {
        var moveVersionDetails = moveData['version_group_details'] as List;
        var isLearnMethodMatch = moveVersionDetails.any((versionDetail) =>
        versionDetail['move_learn_method']['name'] == learnMethod);

        if (isLearnMethodMatch) {
          moveFetchTasks.add(http.get(Uri.parse(moveData['move']['url'])));
        }
      }

      var moveResponses = await Future.wait(moveFetchTasks);
      List<Move> movesList = moveResponses.map((response) {
        var moveDetails = json.decode(response.body);

        var moveName = moveDetails['name'];
        var movePower = moveDetails['power'] ?? -1; // Usar valores predeterminados si son null
        var movePP = moveDetails['pp'] ?? -1;
        var moveAccuracy = moveDetails['accuracy'] ?? -1;
        var moveType = moveDetails['type']['name'];
        var moveDamageClass = moveDetails['damage_class']['name'];

        return Move(
          name: moveName,
          power: movePower,
          pp: movePP,
          accuracy: moveAccuracy,
          type: moveType,
          damageClass: moveDamageClass,
          learnMethod: learnMethod, // Este valor viene del argumento de 'loadMoves'
        );
      }).toList();


      this.moves = movesList;
    } catch (e) {
      print("Error loading moves: $e");
    }
  }

}

class Ability {
  final String name;
  final String description;
  final List<String> pokemonUseList;

  Ability({
    required this.name,
    required this.description,
    required this.pokemonUseList,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: json['name' ] as String,
      description: json['description'] as String,
      pokemonUseList: [],
    );
  }
}

class PokemonCard {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  PokemonCard.fromPokemonDB(PokemonDB pokemonDB)
      : id = pokemonDB.id,
        name = pokemonDB.name,
        imageUrl = pokemonDB.image,
        types = [pokemonDB.type];
}

