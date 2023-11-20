import 'package:flutter/material.dart';
import 'package:pokedex_proyecto_final/Entities/Pokemon.dart';
import '../screens/details_screen.dart';
import '../screens/favorite_screen.dart';

class GifViewer extends StatefulWidget {
  final PokemonCard pokemonCard;
  final Color color;

  const GifViewer({
    Key? key,
    required this.pokemonCard,
    required this.color,
  }) : super(key: key);

  @override
  _GifViewerState createState() => _GifViewerState();
}

class _GifViewerState extends State<GifViewer> {
  final String charmanderGifPath = 'images/charmander-loading.gif';

  @override
  void initState() {
    super.initState();

    // Simula un tiempo de carga para propósitos de demostración
    Future.delayed(const Duration(seconds: 3), () {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              charmanderGifPath,
              width: 175,
              height: 175,
            ),
            const SizedBox(height: 50),
            const Text('Cargando...'),
          ],
        ),
      ),
    );
  }
}