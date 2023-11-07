import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex_proyecto_final/poke_database.dart';

import 'home_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Pokemon pokemon;
  final Color color;

  DetailsScreen(this.pokemon, this.color);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: widget.color,
      body: Stack(
        alignment: Alignment.center,
        children: [
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
          const Positioned(
            top: 75,
            left: 50,
            child: Text(
              "Pokedex",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
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
              height: height * 0.6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      buildSectionButton(0, "ABOUT"),
                      buildSectionButton(1, "STATS"),
                      buildSectionButton(2, "EVS"),
                      buildSectionButton(3, "MOVES"),
                      buildSectionButton(4, "SKILLS"),
                    ],
                  ),
                  SizedBox(height: 20),
                  buildSectionContent(selectedSection),
                ],
              ),
            ),
          ),
          Positioned(
              top: (height * 0.18),
              left: (width / 2) - 100,
              child:
              Hero(
                tag: 'pokemon-${widget.pokemon.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.pokemon.imageUrl,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  height: 200,
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
        child: Container(
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
      ),
    );
  }

  Widget buildSectionContent(int sectionIndex) {
    switch (sectionIndex) {
      case 0: // ABOUT
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                '#${widget.pokemon.id}',
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.pokemon.name,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.pokemon.types.map((type) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: widget.color.withOpacity(0.8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4.0),
                      child: Text(
                        type,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(widget.pokemon.weight / 10)} KG',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 50),
                  Text(
                    '${widget.pokemon.height / 10} M',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Peso',
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 75),
                  Text(
                    'Altura',
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 1: // STATS
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: const Column(
            children: [
              // Aqui van las estadisticas
            ],
          ),
        );
      case 2: // EVOLUTIONS
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Aqui van las evoluciones
            ],
          ),
        );
      case 3: // MOVES
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Aqui van los movimientos
            ],
          ),
        );
      case 4: // MOVES
        return Container(
          height: 400,
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchData(widget.pokemon.name),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return ListView.builder(
                  padding: EdgeInsets.only(top: 6.0), // Ajusta el padding superior
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                color: widget.color,
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    '${snapshot.data![index]["name"]}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    '${snapshot.data![index]["description"]}',
                                    style: TextStyle(fontSize: 16),
                                  ),
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
          ),
        );
      default:
        return Container();
    }
  }
}

//---------------------------------------------------------------------
class PokemonDetails {
  final List<Stat> stats;
  final List<String> abilities;
  final List<String> evolutions;
  final List<String> moves;

  PokemonDetails({
    required this.stats,
    required this.abilities,
    required this.evolutions,
    required this.moves,
  });

  factory PokemonDetails.fromJson(Map<String, dynamic> json) {
    return PokemonDetails(
      stats: (json['stats'] as List).map((e) => Stat.fromJson(e)).toList(),
      abilities: (json['abilities'] as List)
          .map((e) => e['ability']['name'] as String)
          .toList(),
      evolutions: [],
      moves: (json['moves'] as List)
          .map((e) => e['move']['name'] as String)
          .toList(),
    );
  }
}

class Stat {
  final String name;
  final int value;

  Stat({required this.name, required this.value});

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      name: json['stat']['name'] as String,
      value: json['base_stat'] as int,
    );
  }
}

Future<List<Map<String, dynamic>>> fetchData(String pokemon) async {
  var pokemonUrl = "https://pokeapi.co/api/v2/pokemon/$pokemon";
  var response = await http.get(Uri.parse(pokemonUrl));
  var data = json.decode(response.body);

  List<Map<String, dynamic>> abilitiesList = [];

  for (var ability in data['abilities']) {
    var abilitiesUrl = ability['ability']['url'];
    var abilitiesResponse = await http.get(Uri.parse(abilitiesUrl));
    var abilitiesData = json.decode(abilitiesResponse.body);

    // Verificación de la descripción en inglés
    var englishDescription = abilitiesData['effect_entries']
        .firstWhere((entry) => entry['language']['name'] == 'en', orElse: () => null);

    var abilitiesName = abilitiesData['name'];
    var abilitiesDescription = englishDescription != null
        ? englishDescription['effect']
        : "Descripción no disponible en inglés";

    abilitiesList.add({'name': abilitiesName, 'description': abilitiesDescription});
  }

  return abilitiesList;
}

