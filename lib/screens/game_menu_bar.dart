import 'package:flutter/material.dart';
import 'package:pokedex_proyecto_final/games/game_1.dart';

class MenuMinijuegos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú de Minijuegos'),
        backgroundColor: Colors.purple, // Color personalizado para la AppBar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Fondo con degradado
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          children: <Widget>[
            _buildGameTile(context, "Who's that pokemon?",
                const JuegoAdivinarPokemon(), 'images/pikachu.png'),
            //_buildGameTile(context, 'Minijuego 2', Minijuego2Screen()), // Asegúrate de descomentar y actualizar
            // Agrega más opciones de minijuegos según sea necesario
          ],
        ),
      ),
    );
  }

  Widget _buildGameTile(
      BuildContext context, String title, Widget gameScreen, String assetPath) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% del ancho de la pantalla
      height: 150, // Altura fija para la Card
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Esquinas redondeadas para el Card
        ),
        margin: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => gameScreen));
          },
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0), // Bordes redondeados para el Container
                  gradient: const LinearGradient(
                    // Fondo con degradado
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.red,
                      Colors.blue,
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(left: 16.0, right: 120), // Aumentar padding izquierdo
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Color de texto para mejor contraste
                  ),
                ),
              ),
              Positioned(
                right: 0, // Posiciona la imagen a la derecha
                top: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0), // Bordes redondeados para la imagen
                  child: Image.asset(
                    assetPath,
                    width: 100, // Ancho fijo para la imagen
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.5),
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
