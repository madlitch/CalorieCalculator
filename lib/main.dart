import 'package:flutter/material.dart';
import 'package:caloriecalc/widgets/home_screen.dart';

var colorScheme = ColorScheme.fromSeed(
  seedColor: Colors.lightBlue,
);

// have main app separate for navigation purposes
void main() {
  runApp(
    MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme: colorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: colorScheme.onPrimaryContainer,
          foregroundColor: colorScheme.primaryContainer,
        ),
        cardTheme: const CardTheme().copyWith(
          color: colorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
                fontSize: 16,
              ),
            ),
      ),
      initialRoute: '/',
      routes: {'/': (context) => const HomeScreen()},
    ),
  );
}
