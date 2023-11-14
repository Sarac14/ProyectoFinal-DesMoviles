import 'dart:convert';
import 'package:http/http.dart' as http;

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  late final List<Ability> abilities;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
  });

  void setAbilities(List<Ability> newAbilities) {
    abilities = newAbilities;
  }

  List<Ability> getAbilities() {
    return abilities;
  }

  factory Pokemon.fromJson(Map<String, dynamic> json, List<Ability> listAbilities) {var typeList = (json['types'] as List)
      .map((typeData) {
    if (typeData is Map<String, dynamic>) {
      // Algunas veces, el campo 'type' puede ser un mapa.
      return typeData['type']['name'] as String;
    } else if (typeData is String) {
      // Otras veces, el campo 'type' puede ser directamente una cadena.
      print("NOT NULL");
      return typeData;
    } else {
      // En caso de que el formato no sea el esperado, puedes manejarlo de alguna manera.
      print("NULL");
      return 'Tipo Desconocido';
    }
  })
      .toList();

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] as String,
      types: typeList,
      height: (json['height']) as int,
      weight: (json['weight']) as int,
      abilities: listAbilities,
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
}