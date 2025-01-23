import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waygo/infoHandler/app_info.dart';
import 'package:waygo/screens/searchPlaceScreen.dart';  // Ensure you need this import
import 'package:waygo/screens/signUpScreen.dart';
import 'package:waygo/splash/splashScreen.dart';
import 'package:waygo/themeProvider/theme_provider.dart';  // Make sure MyThemes is properly implemented

import 'firebase_options.dart';  // Ensure this file exists and is generated correctly by Firebase

void main() async {
  // Initialize Flutter bindings (required before Firebase setup)
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the correct platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Make sure you have this correctly set up
  );

  // Run the app once Firebase is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'WayGo App',  // Set your app title here
        themeMode: ThemeMode.system,  // Switch between light and dark based on system preferences
        theme: MyThemes.lightTheme,  // Define light theme in MyThemes
        darkTheme: MyThemes.darkTheme,  // Define dark theme in MyThemes
        debugShowCheckedModeBanner: false,  // Disable debug banner
        home: Splashscreen(),  // Initial screen, ensure Splashscreen() is implemented correctly
      ),
    );
  }
}
