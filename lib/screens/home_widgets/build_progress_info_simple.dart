import 'package:cashflow/screens/home_widgets/build_item_info.dart';
import 'package:flutter/material.dart';

Widget buildProgressInfoSimple(
  BuildContext context,
  double totalEconomise,
  int daysLeft,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildInfoItem(
        context,
        'Épargné',
        '$totalEconomise FCFA',
        Icons.savings_outlined,
      ),
      buildInfoItem(
        context,
        'Jours restants',
        '$daysLeft jours',
        Icons.timer_outlined,
      ),
    ],
  );
}
