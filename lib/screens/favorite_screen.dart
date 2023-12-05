import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pokedex_proyecto_final/Entities/Pokemon.dart';
import 'package:http/http.dart' as http;
import '../database/poke_database.dart';
import '../widgets/animation.dart';
import 'details_screen.dart';
import 'home_screen.dart';

class FavoritePokemonScreen extends StatefulWidget {
  const FavoritePokemonScreen({super.key});

  @override
  _FavoritePokemonScreenState createState() => _FavoritePokemonScreenState();
}

class _FavoritePokemonScreenState extends State<FavoritePokemonScreen> {
  late Future<List<PokemonCard>> _favoritePokemonFuture;
  Set<int> favoritePokemons = <int>{};
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Cargando la lista de Pokémon favoritos al inicio.
    loadFavoritePokemons();
    // Obtiene datos de Pokémon a partir de las URLs almacenadas en la base de datos.
    _favoritePokemonFuture = enviandoUrlFavoritoApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Pokemon')),
      body: FutureBuilder<List<PokemonCard>>(
        future: _favoritePokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
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
                            builder: (_) => GifViewer(pokemonCard: pokemon,
                                color: getColorForType(pokemon.types))));
                  },
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Stack(
                      children: [
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
                            capitalize(pokemon.name),
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
                                capitalize(pokemon.types.first),
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
          } else {
            return const Center(
                child: Text('La lista de favoritos se encuentra vacia'));
          }
        },
      ),
    );
  }

  Future<void> loadFavoritePokemons() async {
    final favoriteList = await PokeDatabase.instance.getFavoritePokemons();
    setState(() {
      favoritePokemons =
          Set<int>.from(favoriteList.map((pokemon) => pokemon.id));
    });
  }
}

Future<List<PokemonCard>> enviandoUrlFavoritoApi() async {
  List<String> urls = await PokeDatabase.instance.getFavoritePokemonUrls();
  return fetchFavoritePokemonCards();
}

void showErrorMessage(String message) {
  ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  ));
}

Future<Pokemon> pokemonFetchData(String pokemonName) async {
  return await fetchPokemonDetailsData(pokemonName);
}

Future<List<PokemonCard>> fetchFavoritePokemonCards() async {
  List<PokemonDB> favoritePokemonData =
      await PokeDatabase.instance.getFavoritePokemons();
  List<PokemonCard> favoritePokemonCards = [];
  try {
    for (var pokemonData in favoritePokemonData) {
      var pokemon = PokemonCard(
        id: pokemonData.id,
        name: pokemonData.name,
        imageUrl: pokemonData.image,
        types: [pokemonData.type],
      );
      favoritePokemonCards.add(pokemon);
    }
  } catch (error) {
    showErrorMessage(error.toString());
  }
  return favoritePokemonCards;
}
