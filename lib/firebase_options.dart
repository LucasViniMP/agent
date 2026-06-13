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
    apiKey: 'AIzaSyAtYpRrToUxKNPYeGNJdic-2AZdOLIwreU',
    appId: '1:515755675116:web:afc98f8d4a2e0ad13ec4c9',
    messagingSenderId: '515755675116',
    projectId: 'mesamestrre',
    authDomain: 'mesamestrre.firebaseapp.com',
    storageBucket: 'mesamestrre.firebasestorage.app',
    measurementId: 'G-BPSZX18WV0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCH6vj59anyT36EsENbJzwD-K6z7hjYSL0',
    appId: '1:515755675116:android:26afd789aa04a1f43ec4c9',
    messagingSenderId: '515755675116',
    projectId: 'mesamestrre',
    storageBucket: 'mesamestrre.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-o4mh5mWeQBSt1DY5Q9N2W8gkLXE9dT0',
    appId: '1:515755675116:ios:6cde488371afd07d3ec4c9',
    messagingSenderId: '515755675116',
    projectId: 'mesamestrre',
    storageBucket: 'mesamestrre.firebasestorage.app',
    iosBundleId: 'com.example.mesamestre',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAMDElLdgvNBNJ5VvJtbU5x0gi2sgOtJdo',
    appId: '1:525546964064:ios:2674dd8531edad80d32f05',
    messagingSenderId: '525546964064',
    projectId: 'mesamestre-123',
    storageBucket: 'mesamestre-123.firebasestorage.app',
    iosBundleId: 'com.example.mesamestre',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAVcQVsO0zXnnod5QsKjF6ZtbZDKrFjBeY',
    appId: '1:525546964064:web:7b8248a393ef00d3d32f05',
    messagingSenderId: '525546964064',
    projectId: 'mesamestre-123',
    authDomain: 'mesamestre-123.firebaseapp.com',
    storageBucket: 'mesamestre-123.firebasestorage.app',
  );
}
