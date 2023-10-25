import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pokedex_proyecto_final/details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _pageSize = 20;
  final PagingController<int, Map<String, dynamic>> _pagingController =
  PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      fetchPokemonData(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height =  MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -50,
              right: -50,
              child: Image.asset('images/pokeball.png', width: 200, fit: BoxFit.fitHeight,),
          ),
          const Positioned(
            top: 80,
              left: 20,
              child: Text("Pokedex",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),)
          ),
          Positioned(
            top: 150,
            bottom: 0,
            width: width,
            child: PagedGridView<int, Map<String, dynamic>>(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
            ),
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
              itemBuilder: (context, item, index) {
                var type = item['type'];
                return  InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                       // color: Colors.green,
                        color: type == "grass" ? Colors.greenAccent : type == "fire" ? Colors.redAccent
                            :type == "water" ? Colors.blue : type == "poison" ? Colors.deepPurpleAccent
                            : type == "electric" ? Colors.amber : type == "rock" ? Colors.grey
                            : type == "ground" ? Colors.brown : type == "psychic" ? Colors.indigo
                            : type == "fighting" ? Colors.orange : type == "bug" ? Colors.lightGreenAccent
                            : type == "ghost" ? Colors.deepPurple : type == "normal" ? Colors.black26 : Colors.pink,
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                      ),
                  //  color: Colors.green,
               // child: Stack(
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: Image.asset('images/pokeball.png',
                          height: 100,
                          fit: BoxFit.fitHeight,)),
                            Positioned(
                              top: 20,
                              left: 10,
                              child: Text(
                                  item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18,
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
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 4),
                                child: Text(
                                    type.toString(),
                                  style: const TextStyle(
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
                                imageUrl: extractImageUrlFromUrl(item['url']),
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                height: 100,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                      ],
                    ),
                    ),
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(
                         item,
                        type == "grass" ? Colors.greenAccent : type == "fire" ? Colors.redAccent
                            :type == "water" ? Colors.blue : type == "poison" ? Colors.deepPurpleAccent
                            : type == "electric" ? Colors.amber : type == "rock" ? Colors.grey
                            : type == "ground" ? Colors.brown : type == "psychic" ? Colors.indigo
                            : type == "fighting" ? Colors.orange : type == "bug" ? Colors.lightGreenAccent
                            : type == "ghost" ? Colors.deepPurple : type == "normal" ? Colors.black26 : Colors.pink,
                        index,
                        extractImageUrlFromUrl(item['url']))));
                  },
                );
              }
            ),
        ),
          ),
        ],
      ),
    );
  }

  // Future<void> fetchPokemonData(int offset) async {
  //   try {
  //     var url = Uri.https("pokeapi.co", "/api/v2/pokemon", {
  //       "offset": offset.toString(),
  //       "limit": _pageSize.toString(),
  //     });
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final nextItems = (data['results'] as List).cast<Map<String, dynamic>>();
  //
  //       final isLastPage = nextItems.length < _pageSize;
  //       if (isLastPage) {
  //         _pagingController.appendLastPage(nextItems);
  //       } else {
  //         _pagingController.appendPage(nextItems, offset + _pageSize);
  //       }
  //     } else {
  //       _pagingController.error = "Error fetching data";
  //     }
  //
  //   } catch (error) {
  //     _pagingController.error = error;
  //   }
  // }

  Future<void> fetchPokemonData(int offset) async {
    try {
      var url = Uri.https("pokeapi.co", "/api/v2/pokemon", {
        "offset": offset.toString(),
        "limit": _pageSize.toString(),
      });
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nextItems = (data['results'] as List).cast<Map<String, dynamic>>();

        // Obtener los tipos de los Pokémon
        for (var item in nextItems) {
          final detailsResponse = await http.get(Uri.parse(item['url']));
          if (detailsResponse.statusCode == 200) {
            final detailsData = jsonDecode(detailsResponse.body);
            item['type'] = detailsData['types'][0]['type']['name'];
          } else {
            item['type'] = 'Unknown';
          }
        }

        final isLastPage = nextItems.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(nextItems);
        } else {
          _pagingController.appendPage(nextItems, offset + _pageSize);
        }
      } else {
        _pagingController.error = "Error fetching data";
      }

    } catch (error) {
      _pagingController.error = error;
    }
  }


  String extractImageUrlFromUrl(String url) {
    final id = url.split('/').reversed.elementAt(1);
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }


  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
