import 'dart:math';
import 'package:flutter/material.dart';
import '../database/poke_database.dart';

class JuegoAdivinarPokemon extends StatefulWidget {
  const JuegoAdivinarPokemon({Key? key}) : super(key: key);

  @override
  _JuegoAdivinarPokemonState createState() => _JuegoAdivinarPokemonState();
}

class _JuegoAdivinarPokemonState extends State<JuegoAdivinarPokemon> {
  List<String> pokemonNames = [];
  String? currentPokemonName;
  String? currentPokemonImageUrl;
  List<String> options = [];
  bool isFiltered = true;
  bool alreadyAnswered = false;

  Color option1Color = Colors.blue;
  Color option2Color = Colors.blue;
  Color option3Color = Colors.blue;

  int aciertos = 0;
  int marcaPersonal = 0;

  @override
  void initState() {
    super.initState();
    _loadPokemonOptions();
  }

  Future<void> _loadPokemonOptions() async {
    pokemonNames = await PokeDatabase.instance.getAllPokemonNames();
    final randomIndex = Random().nextInt(pokemonNames.length);
    final randomPokemonName = pokemonNames[randomIndex];
    final imageUrl = await PokeDatabase.instance.getPokemonImage(randomPokemonName);

    final random = Random();
    options = [randomPokemonName];

    while (options.length < 3) {
      final randomOption = pokemonNames[random.nextInt(pokemonNames.length)];
      if (!options.contains(randomOption)) {
        options.add(randomOption);
      }
    }

    options.shuffle();

    setState(() {
      currentPokemonName = randomPokemonName;
      currentPokemonImageUrl = imageUrl;
      _resetOptionColors();
      isFiltered = true;
      alreadyAnswered = false;
    });
  }

  void _resetOptionColors() {
    option1Color = option2Color = option3Color = Colors.blue;
  }

  void _checkAnswer(String selectedName) {
    if (alreadyAnswered) return;

    _updateOptionColors(selectedName);
    _updateScore(selectedName);

    isFiltered = false;
    alreadyAnswered = true;

    setState(() {});

    Future.delayed(const Duration(seconds: 2), () {
      _loadPokemonOptions();
    });
  }

  void _updateOptionColors(String selectedName) {
    setState(() {
      option1Color = option2Color = option3Color = Colors.red;
      if (currentPokemonName == options[0]) {
        option1Color = Colors.green;
      } else if (currentPokemonName == options[1]) {
        option2Color = Colors.green;
      } else if (currentPokemonName == options[2]) {
        option3Color = Colors.green;
      }
    });
  }

  void _updateScore(String selectedName) {
    if (selectedName == currentPokemonName) {
      aciertos++;
      if (aciertos > marcaPersonal) {
        marcaPersonal = aciertos;
      }
    } else {
      _mostrarDialogoFallo();
    }
  }

  void _mostrarDialogoFallo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.red],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset('images/pikachu-triste.png'),
                Text(
                  'Aciertos: $aciertos',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const Text(
                  '¿Qué te gustaría hacer?',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      aciertos = 0;
                      _loadPokemonOptions();
                    });
                  },
                  child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Salir del Juego', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(String option, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(primary: color),
      child: Text(option, style: const TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.red],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
                  child: Center(
                    child: Text(
                      'Aciertos: $aciertos\nMarca Personal: $marcaPersonal',
                      style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (currentPokemonImageUrl != null)
                          Image.network(
                            currentPokemonImageUrl!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            color: isFiltered ? Colors.black.withOpacity(0.5) : null,
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          'Who`s that Pokémon?',
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        if (currentPokemonName != null && options.isNotEmpty)
                          IntrinsicWidth(
                            child: Column(
                              children: <Widget>[
                                _buildOptionButton(options[0], option1Color, () => _checkAnswer(options[0])),
                                const SizedBox(height: 10),
                                _buildOptionButton(options[1], option2Color, () => _checkAnswer(options[1])),
                                const SizedBox(height: 10),
                                _buildOptionButton(options[2], option3Color, () => _checkAnswer(options[2])),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
