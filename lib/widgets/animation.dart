import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pokedex_proyecto_final/Entities/Pokemon.dart';

import '../screens/details_screen.dart';
import '../screens/favorite_screen.dart';


class GifViewer extends StatefulWidget {
  final List<String> gifPaths;
  final PokemonCard pokemonCard;
  final Color color;

  GifViewer({
    Key? key,
    required this.pokemonCard,
    required this.color,
  })  : gifPaths = [
    'images/pikachu-running.gif',
    'images/charmander-loading.gif',
    'images/pikachu.gif',
    // Agrega más rutas de GIF según sea necesario
  ],
        super(key: key);

  @override
  _GifViewerState createState() => _GifViewerState();
}

class _GifViewerState extends State<GifViewer> {
  late String randomGifPath;

  @override
  void initState() {
    super.initState();

    int randomIndex = Random().nextInt(widget.gifPaths.length);
    randomGifPath = widget.gifPaths[randomIndex];
    pokemonFetchData(widget.pokemonCard.name).then((pokemonDetails) {
      // Utiliza Navigator.pushReplacement para reemplazar la pantalla actual
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DetailsScreen(
            pokemonDetails,
            widget.color,
          ),
        ),
      );
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          randomGifPath,
          width: 125,
          height: 125,
        ),
      ),
    );
  }
}
