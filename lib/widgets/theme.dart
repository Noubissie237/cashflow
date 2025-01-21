import 'package:flutter/material.dart';

// Couleurs de base
const Color primaryColor = Colors.blue;
const Color secondaryColor = Colors.blueGrey;
const Color successColor = Colors.green;
const Color errorColor = Colors.red;
const Color warningColor = Colors.orange;

// Ombres
final List<BoxShadow> cardShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 5),
  ),
];

// Thème clair
final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    color: primaryColor,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shadowColor: Colors.black.withOpacity(0.1),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
  extensions: <ThemeExtension<dynamic>>[
    AppColors(
      savingsColor: Colors.green,
      goalsColor: Colors.orange,
    ),
  ],
);

// Thème sombre
final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    color: Colors.blueGrey[800],
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  cardTheme: CardTheme(
    color: Colors.grey[800],
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shadowColor: Colors.black.withOpacity(0.1),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  extensions: <ThemeExtension<dynamic>>[
    AppColors(
      savingsColor: Colors.green,
      goalsColor: Colors.orange,
    ),
  ],
);

class AppColors extends ThemeExtension<AppColors> {
  final Color savingsColor;
  final Color goalsColor;

  AppColors({required this.savingsColor, required this.goalsColor});

  @override
  ThemeExtension<AppColors> copyWith({
    Color? savingsColor,
    Color? goalsColor,
  }) {
    return AppColors(
      savingsColor: savingsColor ?? this.savingsColor,
      goalsColor: goalsColor ?? this.goalsColor,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      savingsColor: Color.lerp(savingsColor, other.savingsColor, t)!,
      goalsColor: Color.lerp(goalsColor, other.goalsColor, t)!,
    );
  }
}
