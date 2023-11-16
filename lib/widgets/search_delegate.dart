import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_proyecto_final/Entities/Pokemon.dart';

import '../database/poke_database.dart';
import '../screens/details_screen.dart';
import '../screens/favorite_screen.dart';

class SearchPokemonDelegate extends SearchDelegate<PokemonCard> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, PokemonCard(id: -1, name: '', imageUrl: '', types: []));
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<PokemonCard>>(
      future: PokeDatabase.instance.searchPokemons(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron resultados'));
        } else {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final pokemon = snapshot.data![index];
              var type = pokemon.types.first;
              Color cardColor = getColorForType(pokemon.types);
              return InkWell(
                onTap: () {
                  pokemonFetchData(pokemon.name).then((pokemonDetails) {
                    String name = pokemonDetails.name;
                    print("Este es el POKEMON: $name");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsScreen(
                          pokemonDetails,
                          getColorForType(pokemon.types),
                        ),
                      ),
                    );
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Stack(
                      children: [
                        // Fondo de la tarjeta con la imagen de Pokeball
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: Image.asset(
                            'images/pokeball.png',
                            height: 100,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        // Nombre del Pokémon en la esquina superior izquierda
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
                        // ID del Pokémon en la esquina superior derecha
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
                        // Tipo del Pokémon en la esquina inferior izquierda
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Text(
                                pokemon.types.first,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Imagen del Pokémon en la esquina inferior derecha
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
                ),
              );
            },
          );
        }
      },
    );
  }
}

Color getColorForType(List<String> types) {
  if (types.contains('grass')) {
    return Colors.greenAccent;
  } else if (types.contains('fire')) {
    return Colors.redAccent;
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
    return Colors.grey;
  } else {
    return Colors.pink;
  }
}
