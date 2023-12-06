import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../Entities/Evolution.dart';
import '../Entities/Pokemon.dart';
import '../database/poke_database.dart';
import '../widgets/StatsChart.dart';
import '../widgets/animation.dart';
import 'home_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Pokemon pokemon;
  final Color color;

  const DetailsScreen(this.pokemon, this.color, {super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int selectedSection = 0;
  String selectedMethod = 'level-up';
  bool _shouldReloadMoves = true;
  Set<int> favoritePokemons = <int>{};

  @override
  void initState() {
    super.initState();
    loadFavoritePokemons();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: widget.color,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color,
                  Colors.white54,
                  //widget.color.withOpacity(0.5),
                  Colors.white24,
                  // widget.color,
                ],
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 1,
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          Positioned(
            top: 75,
            left: 50,
            child: Text(
              //"Pokedex",
              capitalize(widget.pokemon.name),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ),
          Positioned(
            top: 113,
            left: 60,
            child: Text(
              //"Pokedex",
              '#${widget.pokemon.id.toString()}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          Positioned(
            top: 75,
            right: 60,
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                // Aquí puedes definir la acción al presionar el botón, por ejemplo:
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
          ),
          Positioned(
            top: 75,
            right: 15,
            child: IconButton(
              // Verificar si el Pokémon actual es un favorito para cambiar el ícono.
              icon: favoritePokemons.contains(widget.pokemon.id)
                  ? const Icon(Icons.favorite, color: Colors.red)
                  : const Icon(Icons.favorite_border_rounded,
                      color: Colors.white),
              onPressed: () {
                setState(() {
                  // Verificar si el Pokémon actual es un favorito para cambiar el ícono.
                  if (favoritePokemons.contains(widget.pokemon.id)) {
                    agregarFavoritePokemon(
                        widget.pokemon.id); // Función para quitar de favoritos
                    favoritePokemons.remove(widget.pokemon.id);
                  } else {
                    agregarFavoritePokemon(
                        widget.pokemon.id); // Función para agregar a favoritos
                    favoritePokemons.add(widget.pokemon.id);
                  }
                  PokeDatabase.instance.printAllFavoritePokemons();
                });
              },
            ),
          ),
          Positioned(
              top: height * 0.2,
              right: -30,
              child: Image.asset(
                'images/pokeball.png',
                height: 200,
                fit: BoxFit.fitHeight,
              )),
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: height * 0.65,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      buildSectionButton(0, "ABOUT"),
                      buildSectionButton(1, "EVS"),
                      buildSectionButton(2, "MOVES"),
                      buildSectionButton(3, "SKILLS"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildSectionContent(selectedSection),
                ],
              ),
            ),
          ),
          Positioned(
            top: (height * 0.15),
            left: (width / 2) - 100,
            child: Hero(
              tag: 'pokemon-${widget.pokemon.id}',
              child: CachedNetworkImage(
                imageUrl: widget.pokemon.imageUrl,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                height: 190,
                fit: BoxFit.fitHeight,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildSectionButton(int sectionIndex, String sectionName) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSection = sectionIndex;
          });
        },
        child: Column(
          children: [
            Text(
              sectionName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            Container(
              width: 40,
              height: 2,
              color: selectedSection == sectionIndex
                  ? widget.color
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionContent(int sectionIndex) {
    switch (sectionIndex) {
      case 0: // ABOUT
        String category = widget.pokemon.category?.split(' ')[0] ?? '';
        String descriptionWithoutNewlines =
            widget.pokemon.description.replaceAll('\n', ' ');
        return Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          descriptionWithoutNewlines,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: capitalizeList(widget.pokemon.types).map((type) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            color: widget.color.withOpacity(0.8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 45,
                            vertical: 4.0,
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoColumn('Category', category),
                      _buildSeparator(widget.color),
                      _buildInfoColumn(
                          'Height', '${widget.pokemon.height / 10} M'),
                      _buildSeparator(widget.color),
                      _buildInfoColumn(
                          'Weight', '${widget.pokemon.weight / 10} KG'),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: widget.color,
                          thickness: 2,
                          indent: 40,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Statistics',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: widget.color,
                          thickness: 2,
                          endIndent: 40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  StatsChart(stats: widget.pokemon.stats),
                ],
              ),
            ),
          ),
        );

      case 1: // Evoluciones
        return widget.pokemon.evolutionChain.isNotEmpty
            ? Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: createEvolutionWidget(
                        widget.pokemon.evolutionChain.first, context, widget.pokemon),
                  ),
                ),
              )
            : const CircularProgressIndicator();

      case 2: // MOVES
        // print(widget.pokemon.moves.where((move) => move.learnMethod == selectedMethod));
        print(selectedMethod);
        return FutureBuilder<void>(
            future: widget.pokemon.moves.isEmpty || _shouldReloadMoves
                ? widget.pokemon.loadMoves(selectedMethod)
                : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error al cargar movimientos'));
              }

              // Agregar esta línea para asegurarse de que los movimientos se hayan recargado
              _shouldReloadMoves = false;
              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                "Learning Methods",
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: SizedBox(
                                  height: 60.0,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 4,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      String item = '';
                                      String selec = '';
                                      switch (index) {
                                        case 0:
                                          item = 'Level up';
                                          selec = 'level-up';
                                          break;
                                        case 1:
                                          item = 'MT';
                                          selec = 'machine';
                                          break;
                                        case 2:
                                          item = 'Egg';
                                          selec = 'egg';
                                          break;
                                        case 3:
                                          item = 'Tutor';
                                          selec = 'tutor';
                                          break;
                                      }

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 5),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            onTap: () {
                                              setState(() {
                                                selectedMethod = selec;
                                                _shouldReloadMoves = true;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15)),
                                                color: selectedMethod == selec
                                                    ? widget.color
                                                        .withOpacity(0.5)
                                                    : widget.color,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 10,
                                              ),
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columnSpacing: 10,
                            horizontalMargin: 10,
                            dataRowHeight: 60,
                            columns: const [
                              DataColumn(label: Text('Move')),
                              DataColumn(label: Text('Power')),
                              DataColumn(label: Text('Acurrency')),
                              DataColumn(label: Text('PP')),
                            ],
                            rows: widget.pokemon.moves
                                //.where((move) => move.learnMethod == selectedMethod)
                                .map(
                                  (move) => DataRow(
                                    cells: [
                                      DataCell(
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(capitalize(move.name)),
                                            const SizedBox(height: 5),
                                            _buildTypeBox(move.type,
                                                getColorForType([move.type])),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(move.power == -1
                                                ? '-'
                                                : capitalize(
                                                    move.power.toString())),
                                            const SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(move.accuracy == -1
                                                ? '-'
                                                : capitalize(
                                                    move.accuracy.toString())),
                                            const SizedBox(height: 5),
                                            _buildDamageBox(move.damageClass),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(move.pp == -1
                                                ? '-'
                                                : capitalize(
                                                    move.pp.toString())),
                                            const SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });

      case 3: // HABILIDADES
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.525,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.pokemon.getAbilities().map((ability) {
                  return AbilityCard(
                    color: widget.color,
                    abilityName: capitalize(ability.name),
                    abilityDescription: ability.description,
                    pokemonCanUse: ability.pokemonUseList,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Future<void> loadFavoritePokemons() async {
    final favoriteList = await PokeDatabase.instance.getFavoritePokemons();
    setState(() {
      favoritePokemons =
          Set<int>.from(favoriteList.map((pokemon) => pokemon.id));
    });
  }
}

Widget createEvolutionWidget(Evolution evolution, BuildContext context, pokemon) {
  List<Widget> evolutionWidgets = [];

  // Añade el contenedor del Pokémon actual.
  evolutionWidgets.add(evolutionContainer(evolution, context, pokemon));

  // Si hay evoluciones, procesa cada una.
  if (evolution.evolvesTo.isNotEmpty) {
    // Añade una flecha solo si hay evoluciones.
    evolutionWidgets.add(
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Icon(Icons.arrow_downward, color: Colors.black),
      ),
    );

    // Añade las evoluciones en una nueva fila.
    if (evolution.evolvesTo.length > 4) {
      evolutionWidgets.add(
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          children: evolution.evolvesTo.map((nextEvolution) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: createEvolutionWidget(nextEvolution, context, pokemon),
            );
          }).toList(),
        ),
      );
    } else {
      evolutionWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: evolution.evolvesTo.map((nextEvolution) {
            // Crea un widget para cada evolución.
            return Expanded(
              child: createEvolutionWidget(nextEvolution, context, pokemon),
            );
          }).toList(),
        ),
      );
    }
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: evolutionWidgets,
  );
}

Widget evolutionContainer(Evolution evolution, BuildContext context, Pokemon pokemon) {
  return GestureDetector(
    onTap: () async {
    if (evolution.name != pokemon.name){
      try {
        var pokemonDetails =
            await PokeDatabase.instance.getPokemonByName(evolution.name);
        if (pokemonDetails != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  GifViewer(
                    pokemonCard: pokemonDetails,
                    color: getColorForType(pokemonDetails.types),
                  ),
            ),
          );
        }
      } catch (e) {
        print("Error al obtener detalles del Pokémon: $e");
      }
  }
    },
    child: Container(
      margin: const EdgeInsets.all(10.0),
      alignment: Alignment.center,
      height: 85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Image.asset(
              'images/imgPokeball2.png',
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          CachedNetworkImage(
            imageUrl:
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${evolution.id}.png',
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            height: 90,
            fit: BoxFit.fitHeight,
          ),
          Positioned(
            bottom: 0,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Text(
                    capitalize(evolution.name),
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                if (evolution.minLevel != null)
                  Text("Nivel mínimo: ${evolution.minLevel}"),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Método para construir el rectángulo de daño
Widget _buildDamageBox(String damageClass) {
  Color color;
  if (damageClass == 'physical') {
    color = Colors.redAccent;
  } else if (damageClass == 'special') {
    color = Colors.deepPurpleAccent;
  } else {
    color = Colors.orangeAccent;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.3),
        ],
      ),
    ),
    child: Row(
      children: [
        const Text(
          'Damage',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          capitalize(damageClass),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// Método para construir el rectángulo del tipo
Widget _buildTypeBox(String type, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.5),
        ],
      ),
    ),
    child: Row(
      children: [
        const Text(
          'Type',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          capitalize(type),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class AbilityCard extends StatefulWidget {
  final Color color;
  final String abilityName;
  final String abilityDescription;
  final List<String> pokemonCanUse;

  const AbilityCard({
    Key? key,
    required this.color,
    required this.abilityName,
    required this.abilityDescription,
    required this.pokemonCanUse,
  }) : super(key: key);

  @override
  _AbilityCardState createState() => _AbilityCardState();
}

// Método auxiliar para construir las columnas de información
Widget _buildInfoColumn(String title, String value) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        title,
        style: const TextStyle(
          color: Colors.black38,
          fontSize: 14,
        ),
      ),
    ],
  );
}

Widget _buildSeparator(Color color) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 25),
    height: 35,
    width: 1.5,
    color: color,
  );
}

class _AbilityCardState extends State<AbilityCard> {
  bool isExpanded = false;
  List<PokemonCard> pokemons = [];

  @override
  void initState() {
    super.initState();
    loadPokemons();
  }

  void loadPokemons() async {
    // Suponiendo que searchMultiplePokemons es asíncrona
    var pokemonCards = await PokeDatabase.instance
        .searchMultiplePokemons(widget.pokemonCanUse);
    setState(() {
      pokemons = pokemonCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.abilityName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
              if (isExpanded)
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  "Description",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.abilityDescription,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                                textAlign: TextAlign.justify,
                              ),
                              // const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            "Pokemon with this ability",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            // Dos elementos por fila
                            childAspectRatio: 3 / 2,
                            // Ajusta la proporción según sea necesario
                            crossAxisSpacing: 1,
                            // Espaciado horizontal entre los elementos
                            mainAxisSpacing:
                                1, // Espaciado vertical entre los elementos
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: pokemons.length,
                          itemBuilder: (context, index) {
                            return buildPokemonCard(context, pokemons[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildPokemonCard(BuildContext context, PokemonCard pokemon) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => GifViewer(
                  pokemonCard: pokemon,
                  color: getColorForType(pokemon.types))));
    },
    child: Card(
      color: getColorForType(pokemon.types),
      // Reemplaza con el color que desees
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: SizedBox(
        height: 200,
        // Ajusta esta altura según sea necesario
        width: double.infinity,
        // Esto hará que tome el ancho completo disponible
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
                  fontSize: 14,
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
                  fontSize: 16,
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
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 4, bottom: 4),
                  child: Text(
                    capitalize(pokemon.types.first),
                    style: const TextStyle(
                      fontSize: 12,
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
                errorWidget: (context, url, error) => const Icon(Icons.error),
                height: 80,
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class AbilityDetailsScreen extends StatelessWidget {
  final String abilityName;
  final String abilityDescription;

  const AbilityDetailsScreen(
      {super.key, required this.abilityName, required this.abilityDescription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(abilityName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(abilityDescription),
      ),
    );
  }
}
