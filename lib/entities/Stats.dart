class Stats {
  final int baseHp;
  final int baseAttack;
  final int baseDefense;
  final int baseSpecialAttack;
  final int baseSpecialDefense;
  final int baseSpeed;

  Stats({
    required this.baseHp,
    required this.baseAttack,
    required this.baseDefense,
    required this.baseSpecialAttack,
    required this.baseSpecialDefense,
    required this.baseSpeed,
  });

  factory Stats.fromJson(List<dynamic> statsData) {
    return Stats(
      baseHp: statsData[0]['base_stat'],
      baseAttack: statsData[1]['base_stat'],
      baseDefense: statsData[2]['base_stat'],
      baseSpecialAttack: statsData[3]['base_stat'],
      baseSpecialDefense: statsData[4]['base_stat'],
      baseSpeed: statsData[5]['base_stat'],
    );
  }
}