import 'package:cashflow/models/caisse.dart';
import 'package:cashflow/screens/add_edit_objectif_screen.dart';
import 'package:cashflow/widgets/savings_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoObjectivesCard extends StatelessWidget {
  final List<Caisse> caisseList;
  final int utilisateurId;

  const NoObjectivesCard(
      {super.key, required this.caisseList, required this.utilisateurId});

  @override
  Widget build(BuildContext context) {
    final totalEconomise = caisseList.fold<double>(
      0,
      (sum, caisse) => sum + caisse.montant,
    );

    String message = totalEconomise == 0.0 ? "commencer" : "continuer";

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.savings_outlined,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Vous avez économisé ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0).format(totalEconomise)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Vous pouvez $message à économiser librement ou définir un objectif pour suivre votre progression.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditObjectifScreen(
                        utilisateurId: utilisateurId,
                      ),
                    ),
                  ),
                  child: const Text('Définir un objectif (optionnel)'),
                ),
              ],
            ),
          ),
        ),
        if (caisseList.isNotEmpty) SavingsSummaryCard(caisseList: caisseList),
      ],
    );
  }
}
