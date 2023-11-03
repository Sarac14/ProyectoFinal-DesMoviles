import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path/path.dart';
import 'package:pokedex_proyecto_final/poke_database.dart';
import 'package:http/http.dart' as http;


class FavoritePokemonScreen extends StatefulWidget {
  @override
  _FavoritePokemonScreenState createState() => _FavoritePokemonScreenState();
}

class _FavoritePokemonScreenState extends State<FavoritePokemonScreen> {
  late Future<List<PokemonItem>> _favoritePokemonFuture;

  @override
  void initState() {
    super.initState();
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
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pokemon = snapshot.data![index];
                return InkWell(
                  onTap: () {
                    // Aquí puedes agregar la lógica para manejar el tap en un Pokémon específico
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: pokemon.imageUrl,
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            pokemon.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
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
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
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