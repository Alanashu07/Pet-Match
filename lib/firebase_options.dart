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
    apiKey: 'AIzaSyAohpF7o-VI9a6sHF2XGR8nbF3Ztglsfmo',
    appId: '1:384812486648:web:4a083574cdacfc62b1500d',
    messagingSenderId: '384812486648',
    projectId: 'pet-match-b347c',
    authDomain: 'pet-match-b347c.firebaseapp.com',
    storageBucket: 'pet-match-b347c.appspot.com',
    measurementId: 'G-4XQ6GQL6HC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-UlAdQqrX1eAreF5DprZxXuJS-f9Z3aE',
    appId: '1:384812486648:android:279471a3f38a5133b1500d',
    messagingSenderId: '384812486648',
    projectId: 'pet-match-b347c',
    storageBucket: 'pet-match-b347c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbBPH15UElr8GA5cpNHUW7kaNFBHo-wik',
    appId: '1:384812486648:ios:266e5cf758f48badb1500d',
    messagingSenderId: '384812486648',
    projectId: 'pet-match-b347c',
    storageBucket: 'pet-match-b347c.appspot.com',
    androidClientId: '384812486648-dncnoe58283ccq3vj74kvqve1huikl83.apps.googleusercontent.com',
    iosClientId: '384812486648-s6st47n47kav304uu7no49lnjlruj7id.apps.googleusercontent.com',
    iosBundleId: 'com.example.petMatch',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCbBPH15UElr8GA5cpNHUW7kaNFBHo-wik',
    appId: '1:384812486648:ios:266e5cf758f48badb1500d',
    messagingSenderId: '384812486648',
    projectId: 'pet-match-b347c',
    storageBucket: 'pet-match-b347c.appspot.com',
    androidClientId: '384812486648-dncnoe58283ccq3vj74kvqve1huikl83.apps.googleusercontent.com',
    iosClientId: '384812486648-s6st47n47kav304uu7no49lnjlruj7id.apps.googleusercontent.com',
    iosBundleId: 'com.example.petMatch',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAohpF7o-VI9a6sHF2XGR8nbF3Ztglsfmo',
    appId: '1:384812486648:web:0c7dd83c6d331cddb1500d',
    messagingSenderId: '384812486648',
    projectId: 'pet-match-b347c',
    authDomain: 'pet-match-b347c.firebaseapp.com',
    storageBucket: 'pet-match-b347c.appspot.com',
    measurementId: 'G-4P4SKNW6MW',
  );

}