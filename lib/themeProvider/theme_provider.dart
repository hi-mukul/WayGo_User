import 'package:flutter/material.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: ColorScheme.dark(),
    primaryColor: Colors.green, // Example: setting primary color
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.green, // Example: setting button color for dark mode
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),  // Setting default text color
      bodyMedium: TextStyle(color: Colors.white),
      displayLarge: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Colors.white), // Icon color for dark theme
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(),
    primaryColor: Colors.blue, // Example: setting primary color
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue, // Example: setting button color for light mode
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),  // Setting default text color
      bodyMedium: TextStyle(color: Colors.black),
      displayLarge: TextStyle(color: Colors.black),
    ),
    iconTheme: IconThemeData(color: Colors.black), // Icon color for light theme
  );
}
