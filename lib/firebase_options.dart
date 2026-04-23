// lib/firebase_options.dart
// Generated from classscheduler-b2918 Firebase project.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyCMV14-w25dx_gR3hwAzIeqGXF4CvcbkgU',
    appId:             '1:237070186843:android:f2514a2404facff715027e',
    messagingSenderId: '237070186843',
    projectId:         'classscheduler-b2918',
    storageBucket:     'classscheduler-b2918.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'AIzaSyCMV14-w25dx_gR3hwAzIeqGXF4CvcbkgU',
    appId:             '1:237070186843:ios:f2514a2404facff715027e',
    messagingSenderId: '237070186843',
    projectId:         'classscheduler-b2918',
    storageBucket:     'classscheduler-b2918.firebasestorage.app',
    iosClientId:       '237070186843-dcff0lk2mikv6o2prk6fvlvlahbohhpk.apps.googleusercontent.com',
    iosBundleId:       'com.classscheduler.classscheduler',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyCMV14-w25dx_gR3hwAzIeqGXF4CvcbkgU',
    appId:             '1:237070186843:web:f2514a2404facff715027e',
    messagingSenderId: '237070186843',
    projectId:         'classscheduler-b2918',
    storageBucket:     'classscheduler-b2918.firebasestorage.app',
  );
}
