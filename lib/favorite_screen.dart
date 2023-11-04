import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path/path.dart';
import 'package:pokedex_proyecto_final/home_screen.dart';
import 'package:pokedex_proyecto_final/poke_database.dart';
import 'package:http/http.dart' as http;

import 'details_screen.dart';


class FavoritePokemonScreen extends StatefulWidget {
  @override
  _FavoritePokemonScreenState createState() => _FavoritePokemonScreenState();
}

class _FavoritePokemonScreenState extends State<FavoritePokemonScreen> {
  late Future<List<PokemonItem>> _favoritePokemonFuture;
  Set<int> favoritePokemons = Set<int>();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavoritePokemons();
    _favoritePokemonFuture = enviandoUrlFavoritoApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Pokemon')),
      body: FutureBuilder<List<PokemonItem>>(
        future: _favoritePokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                //crossAxisSpacing: 10,
                //mainAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pokemon = snapshot.data![index];
                Color cardColor = getColorForType(pokemon.types);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsScreen(
                            Pokemon.fromPokemonItem(pokemon), getColorForType(pokemon.types)
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Stack(children: [
                      Positioned(
                          bottom: -10,
                          right: -10,
                          child: Image.asset(
                            'images/pokeball.png',
                            height: 100,
                            fit: BoxFit.fitHeight,
                          )),
                      Positioned(
                        top: 20,
                        left: 10,
                        child: Text(
                          pokemon.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 10,
                        child: Text(
                          pokemon.id.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 45,
                        left: 20,
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(20)),
                            color: Colors.black26,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 4, bottom: 4),
                            child: Text(
                              pokemon.types.first,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                          height: 90,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }else {
            return Center(child: Text('La lista de favoritos se encuentra vacia'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Color getColorForType(List<String> types) {
    if (types.contains('grass')) {
      return Colors.green;
    } else if (types.contains('fire')) {
      return Colors.red;
    } else if (types.contains('water')) {
      return Colors.blue;
    } else if (types.contains('poison')) {
      return Colors.deepPurpleAccent;
    } else if (types.contains('electric')) {
      return Colors.amber;
    } else if (types.contains('rock')) {
      return Colors.grey;
    } else if (types.contains('ground')) {
      return Colors.brown;
    } else if (types.contains('psychic')) {
      return Colors.indigo;
    } else if (types.contains('fighting')) {
      return Colors.orange;
    } else if (types.contains('bug')) {
      return Colors.lightGreen;
    } else if (types.contains('ghost')) {
      return Colors.deepPurple;
    } else if (types.contains('normal')) {
      return Colors.black26;
    } else {
      return Colors.pink;
    }
  }

  Future<void> loadFavoritePokemons() async {
    final favoriteList = await PokeDatabase.instance.getFavoritePokemons();
    setState(() {
      favoritePokemons = Set<int>.from(favoriteList.map((pokemon) => pokemon.id));
    });
  }
}

Future<List<PokemonItem>> enviandoUrlFavoritoApi() async {
  List<String> urls = await PokeDatabase.instance.getFavoritePokemonUrls();
  return fetchSpecificPokemonDataFromUrls(urls);
}

void showErrorMessage(String message) {
  ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  ));
}

Future<List<PokemonItem>> fetchSpecificPokemonDataFromUrls(List<String> pokemonUrls) async {
  List<PokemonItem> pokemonItems = [];
  try {
    for (var url in pokemonUrls) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pokemon = PokemonItem.fromJson(data);
        print('Nombre: ${pokemon.name}, ID: ${pokemon.id}, Tipos: ${pokemon.types}');
        pokemonItems.add(pokemon);
      } else {
        showErrorMessage("Error al obtener datos del Pokémon desde la URL: $url");
      }
    }
  } catch (error) {
    showErrorMessage(error.toString());
  }

  return pokemonItems;

}


class PokemonItem {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;

  const PokemonItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
  });

  factory PokemonItem.fromJson(Map<String, dynamic> json) {
    var typeList = (json['types'] as List)
        .map((typeData) => typeData['type']['name'] as String)
        .toList();

    return PokemonItem(
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