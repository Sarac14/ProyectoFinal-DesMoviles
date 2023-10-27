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
            top: 40,
            left: 1,
            child: IconButton( icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30,),
              onPressed: (){
                Navigator.pop(context);
              }
            ),
          ),
          Positioned(
            top: 90,
              left: 5,
              child: Text(widget.pokemon.name, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30
              ),),
          ),

          Positioned(
            top: 140,
              left: 20,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10),),
                  color: Colors.black26
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                  child: Text(widget.pokemon.types.first, style: const TextStyle(
                    color: Colors.white
                  ),),
                ),
              ),
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
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                        Container(
                            width: width * 0.3,
                            child: const Text("Name", style: TextStyle(
                              color: Colors.blueGrey, fontSize: 18,
                            ),),
                        ),
                            Container(
                              width: width * 0.3,
                              child: Text(widget.pokemon.name,  style: const TextStyle(
                                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold
                              ),),
                            ),
                      ]),
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
