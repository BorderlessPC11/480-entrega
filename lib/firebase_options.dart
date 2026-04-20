// Replace this file by running: flutterfire configure
// https://firebase.google.com/docs/flutter/setup

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Run `flutterfire configure` in the project root to regenerate with your
/// project's real values. Until then, [Firebase.initializeApp] may fail at
/// runtime on device.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-flutterfire-configure',
    authDomain: 'replace-with-flutterfire-configure.firebaseapp.com',
    storageBucket: 'replace-with-flutterfire-configure.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD43T3b-fU2QIe8WCxaMiWOR2IyD_wf5sg',
    appId: '1:215315889197:android:05ee52c0eb00f0a4658ca4',
    messagingSenderId: '215315889197',
    projectId: 'whitelabel-55a14',
    storageBucket: 'whitelabel-55a14.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-flutterfire-configure',
    storageBucket: 'replace-with-flutterfire-configure.appspot.com',
    iosBundleId: 'com.example.borderlessApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-flutterfire-configure',
    storageBucket: 'replace-with-flutterfire-configure.appspot.com',
    iosBundleId: 'com.example.borderlessApp',
  );
}
