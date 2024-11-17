import 'package:UgmaNet/firebase_options.dart';
import 'package:UgmaNet/visual/Screens/app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'ugmanet-e3c8b',
    options: DefaultFirebaseOptions.currentPlatform
  );

  if (kDebugMode) {
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    // firestore.settings = firestore.settings.copyWith(persistenceEnabled: false);
  }
  // var logger = Logger();
  // List<FeedItem> lista = await getFeedItems();
  // logger.d(lista[0].user.imageUrl);
  runApp(const MyApp());
}


