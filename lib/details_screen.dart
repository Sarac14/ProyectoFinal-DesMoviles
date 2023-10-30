import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class DetailsScreen extends StatefulWidget {

  final Pokemon pokemon;
  final Color color;


   DetailsScreen(this.pokemon, this.color);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
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
            child: IconButton( icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30,),
              onPressed: (){
                Navigator.pop(context);
              }
            ),
          ),
          const Positioned(
            top: 75,
              left: 50,
              child: Text("Pokedex", style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25
              ),),
          ),


          Positioned(
              top: height * 0.2,
              right: -30,
              child: Image.asset('images/pokeball.png', height: 200, fit: BoxFit.fitHeight,)
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: height * 0.6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.pokemon.name,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: widget.pokemon.types.map((type) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    color: Colors.black38,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4.0),
                                  child: Text(
                                    type,
                                    style: const TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            top: (height * 0.18),
              left: (width/2) - 100,
              child: CachedNetworkImage(
            imageUrl: widget.pokemon.imageUrl,
                height: 200,
                fit: BoxFit.fitHeight,
          ))

        ],
      ),
    );
  }
}
//---------------------------------------------------------------------
class PokemonDetails {
  //final String name;
  //final List<String> types;
  final List<Stat> stats;
  final List<String> abilities;
  // Supondré que las evoluciones son una lista de nombres de Pokémon por simplicidad
  final List<String> evolutions;
  final List<String> moves;

  PokemonDetails({
    //required this.name,
   // required this.types,
    required this.stats,
    required this.abilities,
    required this.evolutions,
    required this.moves,
  });

  factory PokemonDetails.fromJson(Map<String, dynamic> json) {
    return PokemonDetails(
    //  name: json['name'] as String,
    //  types: (json['types'] as List).map((e) => e['type']['name'] as String).toList(),
      stats: (json['stats'] as List).map((e) => Stat.fromJson(e)).toList(),
      abilities: (json['abilities'] as List).map((e) => e['ability']['name'] as String).toList(),
      // Para evoluciones, tendrías que adaptarlo dependiendo de cómo estés manejando las evoluciones
      evolutions: [], // Esto es solo un marcador de posición
      moves: (json['moves'] as List).map((e) => e['move']['name'] as String).toList(),
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
