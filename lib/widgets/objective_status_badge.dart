import 'package:flutter/material.dart';

class ObjectiveStatusBadge extends StatelessWidget {
  final double totalEconomise;
  final double montantCible;
  final DateTime dateLimite;

  const ObjectiveStatusBadge({
    super.key,
    required this.totalEconomise,
    required this.montantCible,
    required this.dateLimite,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalEconomise / montantCible;
    final daysLeft = dateLimite.difference(DateTime.now()).inDays;

    String text;
    Color backgroundColor;
    Color textColor;

    if (progress >= 1) {
      text = 'Atteint';
      backgroundColor = Colors.green[100]!;
      textColor = Colors.green[900]!;
    } else if (daysLeft <= 0) {
      text = 'Expiré';
      backgroundColor = Colors.red[100]!;
      textColor = Colors.red[900]!;
    } else if (daysLeft <= 7) {
      text = 'Urgent';
      backgroundColor = Colors.orange[100]!;
      textColor = Colors.orange[900]!;
    } else {
      text = 'En cours';
      backgroundColor = Colors.blue[100]!;
      textColor = Colors.blue[900]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
