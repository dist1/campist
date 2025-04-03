import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get platformOptions {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey: "AIzaSyCreQtPM5xIuIPmFP6TsY829K2ghPjQLzc",
        appId: "1:252603503077:android:eaaf205a7e452d95581f0c",
        messagingSenderId: "252603503077",
        projectId: "campist-8f611",
        storageBucket: "campist-8f611.appspot.com", // Corrected storage bucket
      );
    } else if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyAV7Aad9IUAvhAbReCCvgZp--EsQGNdZz8",
        authDomain: "campist-8f611.firebaseapp.com",
        projectId: "campist-8f611",
        storageBucket: "campist-8f611.appspot.com",
        messagingSenderId: "252603503077",
        appId: "1:252603503077:web:54f867d9af88919b581f0c",
        measurementId: "G-F9YJWYJXNR",
      );
    }
    throw UnsupportedError('Unsupported platform');
  }
}
