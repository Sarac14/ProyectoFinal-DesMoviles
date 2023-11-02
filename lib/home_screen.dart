import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pokedex_proyecto_final/details_screen.dart';
import 'package:pokedex_proyecto_final/main.dart';
import 'package:pokedex_proyecto_final/poke_database.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _pageSize = 20;
  final PagingController<int, Pokemon> _pagingController = PagingController(firstPageKey: 0);
  final TextEditingController searchController = TextEditingController();



  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      fetchPokemonData(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height =  MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -50,
              right: -50,
              child: Image.asset('images/pokeball.png', width: 200, fit: BoxFit.fitHeight,),
          ),
          const Positioned(
            top: 70,
              left: 20,
              child: Text("Pokedex",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),)
          ),

          Positioned(
            top: 115,
            left: 20,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.search, size: 26),
                  onPressed: () async {
                    _pagingController.refresh();
                    await fetchPokemonData();
                  },

                ),

                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Buscar Pokemon por numero o nombre',
                      contentPadding: EdgeInsets.zero,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        height: 2.5,
                      ),
                      border: InputBorder.none,
                      suffixIcon:

                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _pagingController.refresh();
                          fetchPokemonData();
                        },
                      )
                    ),
                  ),
                ),
              ],
            ),
          ),




          Positioned(
            top: 150,
            bottom: 0,
            width: width,
            child: PagedGridView<int, Pokemon>(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
            ),
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Pokemon>(
              itemBuilder: (context, pokemon, index) {
                var type = pokemon.types.first;
                var isFavorite = false;
                return  InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                       // color: Colors.green,
                        color: type == "grass" ? Colors.greenAccent : type == "fire" ? Colors.redAccent
                            :type == "water" ? Colors.blue : type == "poison" ? Colors.deepPurpleAccent
                            : type == "electric" ? Colors.amber : type == "rock" ? Colors.grey
                            : type == "ground" ? Colors.brown : type == "psychic" ? Colors.indigo
                            : type == "fighting" ? Colors.orange : type == "bug" ? Colors.lightGreen
                            : type == "ghost" ? Colors.deepPurple : type == "normal" ? Colors.black26 : Colors.pink,
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                      ),
                  //  color: Colors.green,
               // child: Stack(
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: Image.asset('images/pokeball.png',
                          height: 100,
                          fit: BoxFit.fitHeight,)),
                            Positioned(
                              top: 20,
                              left: 10,
                              child: Text(
                                  pokemon.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18,
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
                              fontWeight: FontWeight.bold, fontSize: 18,
                              color: Colors.white,
                            ),

                          ),
                        ),
                          
                        Positioned(
                            top: 45,
                            left: 20,
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Colors.black26,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 4),
                                child: Text(
                                    type.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),Positioned(
                          //top: 5,
                          left: 5,
                          bottom: 10,
                          child: IconButton(
                            icon: isFavorite ? Icon(Icons.favorite, color: Colors.redAccent) : Icon(Icons.favorite_border),
                            onPressed: () {
                              setState(() async {
                                isFavorite = !isFavorite;
                                if (isFavorite) {
                                  await PokeDatabase.instance.insertFavoritePokemon(pokemon.id);
                                  PokeDatabase.instance.printAllFavoritePokemons();
                                  //widget.mainInstance.addFavoritePokemon(widget.database, pokemon.id); // Agrega el Pokemon a la lista de favoritos
                                } else {
                                  await PokeDatabase.instance.insertFavoritePokemon(pokemon.id);
                                  PokeDatabase.instance.printAllFavoritePokemons();
                                  //widget.mainInstance.removeFavoritePokemon(widget.database, pokemon.id); // Elimina el Pokemon de la lista de favoritos
                                }
                              });
                            },
                          ),
                        ),

                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: CachedNetworkImage(
                                imageUrl: pokemon.imageUrl,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                height: 90,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                      ],
                    ),
                    ),
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(
                         pokemon,
                          type == "grass" ? Colors.greenAccent : type == "fire" ? Colors.redAccent
                          :type == "water" ? Colors.blue : type == "poison" ? Colors.deepPurpleAccent
                          : type == "electric" ? Colors.amber : type == "rock" ? Colors.grey
                          : type == "ground" ? Colors.brown : type == "psychic" ? Colors.indigo
                          : type == "fighting" ? Colors.orange : type == "bug" ? Colors.lightGreen
                          : type == "ghost" ? Colors.deepPurple : type == "normal" ? Colors.grey : Colors.pink,

                    )));
                  },
                );
              }
            ),
        ),
          ),
        ],
      ),
    );
  }

  bool isNumeric(String s) {
    return int.tryParse(s) != null;
  }


  Future<void> fetchPokemonData([int offset = 0]) async {
    try {
      Uri url;

      if (searchController.text.isNotEmpty) {
        final isId = isNumeric(searchController.text);

        if (isId) {
          url = Uri.https('pokeapi.co', '/api/v2/pokemon/${int.parse(searchController.text)}');
        } else {
          url = Uri.https('pokeapi.co', '/api/v2/pokemon/${searchController.text.toLowerCase()}');
        }

        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final pokemon = Pokemon.fromJson(data);
          _pagingController.itemList = [pokemon];
          _pagingController.appendLastPage([]);

          return;
        } else {
          showErrorMessage("No se encontró el Pokémon");
          return;
        }
      }

      url = Uri.https('pokeapi.co', '/api/v2/pokemon', {
        "offset": offset.toString(),
        "limit": _pageSize.toString(),
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nextPokemons = (data['results'] as List).map((itemData) async {
          final detailsResponse = await http.get(Uri.parse(itemData['url']));
          final detailsData = jsonDecode(detailsResponse.body);
          return Pokemon.fromJson(detailsData);
        }).toList();

        final pokemonList = await Future.wait(nextPokemons);
        final isLastPage = pokemonList.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(pokemonList);
        } else {
          _pagingController.appendPage(pokemonList, offset + _pageSize);
        }
      } else {
        _pagingController.error = "Error fetching data";
      }

    } catch (error) {
      _pagingController.error = error;
      showErrorMessage(error.toString());
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}


class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;


  const Pokemon({
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
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] as String,
      types: typeList,
      height: (json['height']) as int,
      weight: (json['weight']) as int,
    );
  }
}
