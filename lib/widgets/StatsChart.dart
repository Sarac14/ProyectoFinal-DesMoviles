import 'package:flutter/material.dart';
import '../Entities/Stats.dart';

class StatsChart extends StatelessWidget {
  final Stats stats;

  StatsChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatBar("HP", stats.baseHp, Colors.green),
        _buildStatBar("Attack", stats.baseAttack, Colors.red),
        _buildStatBar("Defense", stats.baseDefense, Colors.blue),
        _buildStatBar("Special Attack", stats.baseSpecialAttack, Colors.purple),
        _buildStatBar("Special Defense", stats.baseSpecialDefense, Colors.yellow),
        _buildStatBar("Speed", stats.baseSpeed, Colors.orange),
      ],
    );
  }

  Widget _buildStatBar(String statName, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  statName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            LinearProgressIndicator(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              value: value / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

}
