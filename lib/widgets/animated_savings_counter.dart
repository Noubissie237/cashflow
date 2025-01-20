import 'package:flutter/material.dart';

class AnimatedSavingsCounter extends StatelessWidget {
  final double amount;
  final TextStyle? style;

  const AnimatedSavingsCounter({
    super.key,
    required this.amount,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Text(
          '${value.toStringAsFixed(0)} FCFA',
          style: style ?? Theme.of(context).textTheme.headlineSmall,
        );
      },
    );
  }
}

