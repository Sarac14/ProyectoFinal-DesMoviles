import 'dart:convert';

import '../database/poke_database.dart';
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
    // required List moves,
    //required this.moves,

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


  // Future<void> loadMoves(String learnMethod) async {
  //   try {
  //
  //     var pokemonUrl = "https://pokeapi.co/api/v2/pokemon/$name";
  //     var response = await http.get(Uri.parse(pokemonUrl));
  //     var data = json.decode(response.body);
  //
  //     // Obtener la lista de movimientos y sus detalles
  //     var movesUrl = data['moves'];
  //     List<Move> movesList = [];
  //     int nMove = 0;
  //
  //     for (var moveData in movesUrl) {
  //       var moveResponse = await http.get(Uri.parse(moveData['move']['url']));
  //       var moveDetails = json.decode(moveResponse.body);
  //
  //       var moveName = moveDetails['name'];
  //       var movePower = moveDetails['power'];
  //       var movePP = moveDetails['pp'];
  //       var moveAccuracy = moveDetails['accuracy'];
  //       var moveType = moveDetails['type']['name'];
  //       var moveDamageClass = moveDetails['damage_class']['name'];
  //       var moveLearnMethod = data['moves'][nMove]['version_group_details'][0]['move_learn_method']['name'];
  //       /*int level = 0;
  //       if(moveLearnMethod == 'level-up'){
  //         level = data['moves'][nMove]['version_group_details'][0]['move_learn_method']['level_learned_at'];
  //       }*/
  //
  //       movesList.add(Move(
  //         name: moveName,
  //         power: movePower ?? -1,
  //         pp: movePP ?? -1,
  //         accuracy: moveAccuracy ?? -1,
  //         type: moveType,
  //         damageClass: moveDamageClass,
  //         learnMethod: moveLearnMethod,
  //        // level: level ?? -1,
  //       ));
  //
  //       nMove = nMove + 1;
  //     }
  //
  //
  //     this.moves = movesList; // Actualizar la lista de movimientos del Pokémon
  //   } catch (e) {
  //     print("Error loading moves: $e");
  //     // Manejo de errores
  //   }
  // }

  // Future<void> loadMoves(String learnMethod) async {
  //   try {
  //     var pokemonUrl = "https://pokeapi.co/api/v2/pokemon/$name";
  //     var response = await http.get(Uri.parse(pokemonUrl));
  //     var data = json.decode(response.body);
  //
  //     var movesData = data['moves'] as List;
  //     List<Move> movesList = [];
  //
  //     for (var moveData in movesData) {
  //       var moveVersionDetails = moveData['version_group_details'] as List;
  //       var isLearnMethodMatch = moveVersionDetails.any((versionDetail) =>
  //       versionDetail['move_learn_method']['name'] == learnMethod);
  //
  //       if (isLearnMethodMatch) {
  //         var moveResponse = await http.get(Uri.parse(moveData['move']['url']));
  //         var moveDetails = json.decode(moveResponse.body);
  //
  //         var moveName = moveDetails['name'];
  //         var movePower = moveDetails['power'];
  //         var movePP = moveDetails['pp'];
  //         var moveAccuracy = moveDetails['accuracy'];
  //         var moveType = moveDetails['type']['name'];
  //         var moveDamageClass = moveDetails['damage_class']['name'];
  //
  //         movesList.add(Move(
  //           name: moveName,
  //           power: movePower ?? -1,
  //           pp: movePP ?? -1,
  //           accuracy: moveAccuracy ?? -1,
  //           type: moveType,
  //           damageClass: moveDamageClass,
  //           learnMethod: learnMethod,
  //         ));
  //       }
  //     }
  //
  //     this.moves = movesList; // Actualizar la lista de movimientos del Pokémon
  //   } catch (e) {
  //     print("Error loading moves: $e");
  //     // Manejo de errores
  //   }
  // }

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

  Ability({
    required this.name,
    required this.description,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: json['name'] as String,
      description: json['description'] as String,
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

