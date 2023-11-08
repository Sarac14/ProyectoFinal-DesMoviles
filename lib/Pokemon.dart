import 'favorite_screen.dart';

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    var typeList = (json['types'] as List)
        .map((typeData) => typeData['type']['name'] as String)
        .toList();

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['sprites']['other']['official-artwork']['front_default']
      as String,
      types: typeList,
      height: (json['height']) as int,
      weight: (json['weight']) as int,
    );
  }
}
