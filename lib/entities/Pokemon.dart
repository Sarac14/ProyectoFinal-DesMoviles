import '../database/poke_database.dart';
import 'Move.dart';
import 'Stats.dart';

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
  late final List<Move> moves;

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
    required this.moves,

  });

  void setAbilities(List<Ability> newAbilities) {
    abilities = newAbilities;
  }

  List<Ability> getAbilities() {
    return abilities;
  }

  factory Pokemon.fromJson(Map<String, dynamic> json, List<Ability> listAbilities, String category, String description, Stats stats, List<Move> moves) {
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
      moves: moves,
    );
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

