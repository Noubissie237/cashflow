import 'package:cashflow/models/caisse.dart';
import 'package:cashflow/widgets/animated_savings_counter.dart';
import 'package:flutter/material.dart';

class SavingsSummaryCard extends StatelessWidget {
  final List<Caisse> caisseList;

  const SavingsSummaryCard({
    super.key,
    required this.caisseList,
  });

  @override
  Widget build(BuildContext context) {
    final totalEpargne = caisseList.fold<double>(
      0,
      (sum, caisse) => sum + caisse.montant,
    );

    final moyenneEpargne = caisseList.isNotEmpty
        ? (totalEpargne / caisseList.length).toDouble()
        : 0.0;

    final dernierEpargne =
        caisseList.isNotEmpty ? caisseList.first.montant.toDouble() : 0.0;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé de vos épargnes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              'Total épargné',
              totalEpargne,
              Icons.savings,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              'Moyenne par épargne',
              moyenneEpargne,
              Icons.analytics,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              'Dernière épargne',
              dernierEpargne,
              Icons.today,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            AnimatedSavingsCounter(
              amount: amount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
