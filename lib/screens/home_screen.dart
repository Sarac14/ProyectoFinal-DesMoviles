import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:path/path.dart';
import '../Entities/Pokemon.dart';
import '../database/poke_database.dart';
import '../Entities/Stats.dart';
import '../widgets/animation.dart';
import '../widgets/search_delegate.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<int> favoritePokemons = <int>{};
  bool isFavorite = false;
  static const _pageSize = 20;
  final PagingController<int, PokemonCard> _pagingController =
      PagingController(firstPageKey: 0);
  final TextEditingController searchController = TextEditingController();
  String? selectedType;

  void _openFavoritePokemonScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritePokemonScreen()),
    );
  }

  void _showFilterOptions(BuildContext context) async {
    List<String> types = await PokeDatabase.instance.getAllPokemonTypes();

    final currentContext = context; // Almacenar la referencia al contexto actual

    // Crear un ScrollController
    ScrollController scrollController = ScrollController();

    final selectedTypeResult = await showDialog<String>(
      context: currentContext, // Usar la referencia almacenada
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona un tipo'),
          content: Container(
            width: 200.0,
            height: 400.0, // Ajusta el ancho del AlertDialog según tus necesidades
            child: Center(
              child: Scrollbar(
                thumbVisibility: true, // Mostrar siempre la barra de desplazamiento
                controller: scrollController,
                child: ListView.builder(
                  controller: scrollController, // Asignar el ScrollController al ListView
                  shrinkWrap: true,
                  itemCount: types.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop(types[index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          capitalize(types[index]),
                          style: TextStyle(fontSize: 16.0), // Ajusta el tamaño del texto aquí
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    if (selectedTypeResult != null) {
      setState(() {
        selectedType = selectedTypeResult;
        _pagingController.refresh();
      });
      print('Filtrar por: $selectedTypeResult');
    }
  }


  @override
  void initState() {
    super.initState();
    loadFavoritePokemons();
    _pagingController.addPageRequestListener((pageKey) {
      fetchPokemonData(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 680,
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Pokedex",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.gamepad, color: Colors.blue),
                        onPressed: () {
                          // Lógica del botón de juego
                        },
                      ),
                      const SizedBox(width: 40), // Espacio entre el icono de juego y el de filtro
                      IconButton(
                        icon: const Icon(Icons.filter_alt, color: Colors.green),
                        onPressed: () {
                          _showFilterOptions(context);
                        },
                      ),
                      const SizedBox(width: 40), // Espacio entre el icono de filtro y el de corazon
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.redAccent),
                        onPressed: () {
                          _openFavoritePokemonScreen(context);
                        },
                      ),
                      const SizedBox(width: 40), // Espacio entre el icono de corazon y el de lupa
                      GestureDetector(
                        onTap: () {
                          showSearch(context: context, delegate: SearchPokemonDelegate());
                        },
                        child: const Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 188,
            bottom: 0,
            width: width,
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
            child: PagedGridView<int, PokemonCard>(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
              ),
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<PokemonCard>(
                  itemBuilder: (context, pokemon, index) {
                var type = pokemon.types.first;
                return InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: getColorForType(pokemon.types),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
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
                                  capitalize(type.toString()),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 5,
                            bottom: 10,
                            child: IconButton(
                              // Verificar si el Pokémon actual es un favorito para cambiar el ícono.
                              icon: favoritePokemons.contains(pokemon.id)
                                  ? const Icon(Icons.favorite, color: Colors.red)
                                  : const Icon(Icons.favorite_border_rounded, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  // Verificar si el Pokémon actual es un favorito para cambiar el ícono.
                                  if (favoritePokemons.contains(pokemon.id)) {
                                    agregarFavoritePokemon(pokemon
                                        .id); // Función para quitar de favoritos
                                    favoritePokemons.remove(pokemon.id);
                                  } else {
                                    agregarFavoritePokemon(pokemon
                                        .id); // Función para agregar a favoritos
                                    favoritePokemons.add(pokemon.id);
                                  }
                                  PokeDatabase.instance
                                      .printAllFavoritePokemons();
                                });
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Hero(
                              tag: 'pokemon-${pokemon.id}',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GifViewer(pokemonCard: pokemon,
                                color: getColorForType(pokemon.types))));
                  },
                );
              }),
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

  Future<void> fetchPokemonData([int pageKey = 0]) async {
    try {
      final offset = pageKey * _pageSize;

      List<PokemonDB> pokemonList;

      if (selectedType != null && selectedType != 'Todos' ) {
        // Si se selecciona un tipo que no es "Todos", filtra por ese tipo
        pokemonList = await PokeDatabase.instance.getPokemonsByTypeAndLimitAndOffset(selectedType!, _pageSize, offset);
      } else {
        // Si no hay tipo seleccionado o es "Todos", obtén todos los Pokémon
        pokemonList = await PokeDatabase.instance.getPokemonsWithLimitAndOffset(_pageSize, offset);
      }

      final pokemonConverted = pokemonList
          .map((pokemon) => PokemonCard(
        id: pokemon.id,
        name: pokemon.name,
        imageUrl: pokemon.image,
        types: [pokemon.type],
      ))
          .toList();

      final isLastPage = pokemonList.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(pokemonConverted);
      } else {
        _pagingController.appendPage(pokemonConverted, pageKey + 1);
      }

      final allPokemonTypes = await PokeDatabase.instance.getAllPokemonTypes();
      print('Todos los tipos de Pokémon: $allPokemonTypes');
    } catch (error) {
      _pagingController.error = error;
      showErrorMessage(error.toString());
    }
  }



  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> loadFavoritePokemons() async {
    final favoriteList = await PokeDatabase.instance.getFavoritePokemons();
    setState(() {
      favoritePokemons =
          Set<int>.from(favoriteList.map((pokemon) => pokemon.id));
    });
  }
}

Future<bool> agregarFavoritePokemon(int pokemonId) async {
  return await PokeDatabase.instance.toggleFavoritePokemon(pokemonId);
}

Future<Pokemon> fetchPokemonDetailsData(String pokemonName) async {
  try {
    // Obtener los detalles básicos del Pokémon
    var pokemonUrl = "https://pokeapi.co/api/v2/pokemon/$pokemonName";
    var response = await http.get(Uri.parse(pokemonUrl));
    var data = json.decode(response.body);

    // Obtener la lista de habilidades
    List<Ability> abilitiesList = [];
    for (var ability in data['abilities']) {
      var abilitiesUrl = ability['ability']['url'];
      var abilitiesResponse = await http.get(Uri.parse(abilitiesUrl));
      var abilitiesData = json.decode(abilitiesResponse.body);

      // Verificación de la descripción en inglés
      var englishDescription = abilitiesData['effect_entries'].firstWhere(
            (entry) => entry['language']['name'] == 'en',
        orElse: () => null,
      );

      var abilitiesName = abilitiesData['name'];
      var abilitiesDescription = englishDescription != null
          ? englishDescription['effect']
          : "Descripción no disponible en inglés";

      abilitiesList.add(Ability(name: abilitiesName, description: abilitiesDescription));
    }

    // Obtener la URL de la especie
    var speciesUrl = data['species']['url'];
    var speciesResponse = await http.get(Uri.parse(speciesUrl));
    var speciesData = json.decode(speciesResponse.body);

    // Obtener la categoría del Pokémon
    var category = speciesData['genera'].firstWhere(
          (entry) => entry['language']['name'] == 'en',
      orElse: () => null,
    )['genus'];

    // Obtener la descripción
    var description = speciesData["flavor_text_entries"].firstWhere(
          (entry) => entry['language']['name'] == 'en',
      orElse: () => null,
    )["flavor_text"];

    // Obtener las estadísticas base
    var statsData = data['stats'];
    var stats = Stats(
      baseHp: statsData[0]['base_stat'],
      baseAttack: statsData[1]['base_stat'],
      baseDefense: statsData[2]['base_stat'],
      baseSpecialAttack: statsData[3]['base_stat'],
      baseSpecialDefense: statsData[4]['base_stat'],
      baseSpeed: statsData[5]['base_stat'],
    );

    Pokemon pokemon = Pokemon.fromJson(data, abilitiesList, category, description, stats);
    return pokemon;
  } catch (e, stackTrace) {
    print("Error in fetchPokemonDetailsData: $e");
    print(stackTrace);
    throw e;
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

String capitalize(String text) {
  if (text == null || text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}
List<String> capitalizeList(List<String> list) {
  if (list == null || list.isEmpty) {
    return list;
  }
  return list.map((text) => capitalize(text)).toList();
}