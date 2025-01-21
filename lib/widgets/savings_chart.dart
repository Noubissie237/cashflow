import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SavingsChart extends StatelessWidget {
  final double totalEconomise;
  final double montantCible;

  SavingsChart({required this.totalEconomise, required this.montantCible});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: totalEconomise,
              color: Colors.green,
              title: 'Économisé',
              radius: 50,
            ),
            PieChartSectionData(
              value: montantCible - totalEconomise,
              color: Colors.red,
              title: 'Restant',
              radius: 50,
            ),
          ],
        ),
      ),
    );
  }
}
