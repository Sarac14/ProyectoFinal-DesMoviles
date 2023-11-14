import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex_proyecto_final/poke_database.dart';

import 'Pokemon.dart';
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
  void initState() {
    super.initState();
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
            child: Hero(
              tag: 'pokemon-${widget.pokemon.id}',
              child: CachedNetworkImage(
                imageUrl: widget.pokemon.imageUrl,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
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
      case 4: // HABILIDADES
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.pokemon.getAbilities().map((ability) {
              return AbilityCard(
                color: widget.color,
                abilityName: ability.name,
                abilityDescription: ability.description,
              );
            }).toList(),
          ),
        );
      default:
        return Container();
    }
  }
}

class AbilityCard extends StatefulWidget {
  final Color color;
  final String abilityName;
  final String abilityDescription;

  const AbilityCard({
    Key? key,
    required this.color,
    required this.abilityName,
    required this.abilityDescription,
  }) : super(key: key);

  @override
  _AbilityCardState createState() => _AbilityCardState();
}

class _AbilityCardState extends State<AbilityCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 4,
        child: GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            color: widget.color,
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget.abilityName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isExpanded) SizedBox(height: 8),
                if (isExpanded)
                  Text(
                    widget.abilityDescription,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AbilityDetailsScreen extends StatelessWidget {
  final String abilityName;
  final String abilityDescription;

  AbilityDetailsScreen(
      {required this.abilityName, required this.abilityDescription});

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
