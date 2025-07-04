import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDeWgqfB2A-2sc-Ieow8JkEufnhc6w58oA',
    appId: '1:138721930336:web:dfb0b9ab982883dd502705',
    messagingSenderId: '138721930336',
    projectId: 'notes-cb88d',
    authDomain: 'notes-cb88d.firebaseapp.com',
    storageBucket: 'notes-cb88d.firebasestorage.app',
    measurementId: 'G-HW6HCY4DYY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDeWgqfB2A-2sc-Ieow8JkEufnhc6w58oA',
    appId: '1:138721930336:android:dfb0b9ab982883dd502705',
    messagingSenderId: '138721930336',
    projectId: 'notes-cb88d',
    storageBucket: 'notes-cb88d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDeWgqfB2A-2sc-Ieow8JkEufnhc6w58oA',
    appId: '1:138721930336:ios:dfb0b9ab982883dd502705',
    messagingSenderId: '138721930336',
    projectId: 'notes-cb88d',
    storageBucket: 'notes-cb88d.firebasestorage.app',
    iosBundleId: 'com.example.notes',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDeWgqfB2A-2sc-Ieow8JkEufnhc6w58oA',
    appId: '1:138721930336:macos:dfb0b9ab982883dd502705',
    messagingSenderId: '138721930336',
    projectId: 'notes-cb88d',
    storageBucket: 'notes-cb88d.firebasestorage.app',
    iosBundleId: 'com.example.notes',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDeWgqfB2A-2sc-Ieow8JkEufnhc6w58oA',
    appId: '1:138721930336:windows:dfb0b9ab982883dd502705',
    messagingSenderId: '138721930336',
    projectId: 'notes-cb88d',
    authDomain: 'notes-cb88d.firebaseapp.com',
    storageBucket: 'notes-cb88d.firebasestorage.app',
  );
}
