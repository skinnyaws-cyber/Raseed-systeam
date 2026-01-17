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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChKFtjXke-6eEiOeP7QxoccK7HutYRKVQ',
    appId: '1:764325356168:web:b29513ea1825d82f01753d',
    messagingSenderId: '764325356168',
    projectId: 'raseedapp-b442e',
    authDomain: 'raseedapp-b442e.firebaseapp.com',
    storageBucket: 'raseedapp-b442e.firebasestorage.app',
    measurementId: 'G-FC6DM87WC0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChKFtjXke-6eEiOeP7QxoccK7HutYRKVQ',
    appId: '1:764325356168:android:b29513ea1825d82f01753d', // افتراضي للأندرويد
    messagingSenderId: '764325356168',
    projectId: 'raseedapp-b442e',
    storageBucket: 'raseedapp-b442e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChKFtjXke-6eEiOeP7QxoccK7HutYRKVQ',
    appId: '1:764325356168:ios:b29513ea1825d82f01753d', // افتراضي للآيفون
    messagingSenderId: '764325356168',
    projectId: 'raseedapp-b442e',
    storageBucket: 'raseedapp-b442e.firebasestorage.app',
    iosBundleId: 'com.example.raseedApp',
  );
}
