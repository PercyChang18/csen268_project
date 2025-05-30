import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xFFFF9100)),
  scaffoldBackgroundColor: const Color(0xFF3B3B3B),
  primaryColor: const Color(0xFFFF9100),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFFD5DBDC),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFFD5DBDC),
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(0xFFD5DBDC),
    ),
    bodyLarge: TextStyle(fontSize: 18, color: Color(0xFFD5DBDC)),
    bodyMedium: TextStyle(fontSize: 16, color: Color(0xFFD5DBDC)),
    bodySmall: TextStyle(fontSize: 14, color: Color(0xFFD5DBDC)),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color(0xFFD5DBDC),
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFFD5DBDC),
    ),
    // this is the sign in page text style
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFFD5DBDC),
    ),
  ),
  // this is the theme for input text boxes
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: Color(0xFFD5DBDC)),
    // text style when float
    floatingLabelStyle: TextStyle(color: Color(0xFFFF9100)),
    hintStyle: TextStyle(color: Color(0xFFD5DBDC)),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFF9100)),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFD5DBDC)),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFF9100)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Color(0xFFFF9100), width: 1.0),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF9100),
      foregroundColor: const Color(0xFF3B3B3B),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFFF9100),
      textStyle: TextStyle(color: Color(0xFFD5DBDC)),
    ),
  ),
  // experimenting colors of the buttons
  // iconButtonTheme: IconButtonThemeData(
  //   style: IconButton.styleFrom(foregroundColor: Color(0xFFFF9100)),
  // ),
  // filledButtonTheme: FilledButtonThemeData(
  //   style: FilledButton.styleFrom(foregroundColor: const Color(0xFFFF9100)),
  // ),
  // this is the sign in button
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(foregroundColor: Color(0xFFD5DBDC)),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF3B3B3B),
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Color(0xFFD5DBDC),
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Color(0xFFD5DBDC)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF3B3B3B),
    selectedIconTheme: IconThemeData(size: 30, color: Color(0xFFFF9100)),
    unselectedIconTheme: IconThemeData(size: 30, color: Color(0xFFD5DBDC)),
    selectedItemColor: Color(0xFFFF9100),
    unselectedItemColor: Color(0xFFD5DBDC),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFFF9100), size: 35),
);
