import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../Entities/Pokemon.dart';
import '../widgets/StatsChart.dart';

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
              widget.pokemon.name,
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
            right: 15,
            child: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
               // _openFavoritePokemonScreen(context);
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
        String category = widget.pokemon.category?.split(' ')[0] ?? '';
        String descriptionWithoutNewlines = widget.pokemon.description.replaceAll('\n', ' ');
        return Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            descriptionWithoutNewlines,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: false,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.pokemon.types.map((type) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                      _buildInfoColumn('Categoría', category),
                      _buildSeparator(widget.color),
                      _buildInfoColumn('Altura', '${widget.pokemon.height / 10} M'),
                      _buildSeparator(widget.color),
                      _buildInfoColumn('Peso', '${widget.pokemon.weight / 10} KG'),
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
                          'Estadísticas',
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




      case 1: // EVOLUTIONS
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Aqui van las evoluciones
            ],
          ),
        );
      case 2: // MOVES
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Aqui van los movimientos
            ],
          ),
        );
      case 3: // HABILIDADES
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: SingleChildScrollView(
            child: Container(
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
            ),
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
    color: color, // Color del Pokémon
  );
}

class _AbilityCardState extends State<AbilityCard> {
  bool isExpanded = false;

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
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget.abilityName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isExpanded)
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.abilityDescription,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
