class Evolution {
  final int id;
  final String name;
  final List<Evolution> evolvesTo; // Lista de posibles evoluciones
  final int? minLevel; // Nivel mínimo para la evolución, si es aplicable

  Evolution({
    required this.id,
    required this.name,
    required this.evolvesTo,
    this.minLevel,
  });

  // Método para crear una instancia de Evolution a partir de un objeto Chain
  factory Evolution.fromChain(Chain chain) {
    return Evolution(
      id: int.parse(chain.species.url.split('/')[6]),
      name: chain.species.name,
      evolvesTo: chain.evolvesTo.map((e) => Evolution.fromChain(e)).toList(),
      minLevel: null, // Aquí puedes añadir lógica para determinar el minLevel si es necesario
    );
  }
}

class EvolutionChain {
  final Chain chain;

  EvolutionChain({required this.chain});

  factory EvolutionChain.fromJson(Map<String, dynamic> json) {
    return EvolutionChain(
      chain: Chain.fromJson(json['chain']),
    );
  }
}

class Chain {
  final Species species;
  final List<Chain> evolvesTo;

  Chain({required this.species, required this.evolvesTo});

  factory Chain.fromJson(Map<String, dynamic> json) {
    var evolvesToList = json['evolves_to'] as List;
    List<Chain> evolvesToChains = evolvesToList.map((e) => Chain.fromJson(e)).toList();

    return Chain(
      species: Species.fromJson(json['species']),
      evolvesTo: evolvesToChains,
    );
  }
}

class Species {
  final String name;
  final String url;

  Species({required this.name, required this.url});

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      name: json['name'],
      url: json['url'],
    );
  }
}

