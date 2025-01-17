// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCp2tDcOYdA0-9ty56CbmQim-MyU259zio',
    appId: '1:441667201235:web:272c2d867b4c8ccfd8cc26',
    messagingSenderId: '441667201235',
    projectId: 'waygo-bc28e',
    authDomain: 'waygo-bc28e.firebaseapp.com',
    storageBucket: 'waygo-bc28e.firebasestorage.app',
    measurementId: 'G-HJYX2BRR28',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCE0GI59jwIGDTK-zgJpn-A7wX_bi7S0Og',
    appId: '1:441667201235:android:2d2072dc87be9201d8cc26',
    messagingSenderId: '441667201235',
    projectId: 'waygo-bc28e',
    storageBucket: 'waygo-bc28e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAT2vDiH6_N4sUI_w6bj9iW2BemFqK5mYc',
    appId: '1:441667201235:ios:76cbfcad1ba22b6ed8cc26',
    messagingSenderId: '441667201235',
    projectId: 'waygo-bc28e',
    storageBucket: 'waygo-bc28e.firebasestorage.app',
    iosBundleId: 'com.example.waygo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAT2vDiH6_N4sUI_w6bj9iW2BemFqK5mYc',
    appId: '1:441667201235:ios:76cbfcad1ba22b6ed8cc26',
    messagingSenderId: '441667201235',
    projectId: 'waygo-bc28e',
    storageBucket: 'waygo-bc28e.firebasestorage.app',
    iosBundleId: 'com.example.waygo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCp2tDcOYdA0-9ty56CbmQim-MyU259zio',
    appId: '1:441667201235:web:663292a8bf715e03d8cc26',
    messagingSenderId: '441667201235',
    projectId: 'waygo-bc28e',
    authDomain: 'waygo-bc28e.firebaseapp.com',
    storageBucket: 'waygo-bc28e.firebasestorage.app',
    measurementId: 'G-YT3VC74V31',
  );
}
