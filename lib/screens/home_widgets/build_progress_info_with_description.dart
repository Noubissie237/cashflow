import 'package:cashflow/screens/home_widgets/build_item_info.dart';
import 'package:flutter/material.dart';

Widget buildProgressInfoWithDescription(
  BuildContext context,
  double totalEconomise,
  int daysLeft,
  String description,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
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
      ),
      if (description.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
    ],
  );
}
