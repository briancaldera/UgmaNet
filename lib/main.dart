import 'package:UgmaNet/firebase_options.dart';
import 'package:UgmaNet/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:UgmaNet/visual/Screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'ugmanet-e3c8b',
    options: DefaultFirebaseOptions.currentPlatform
  );

  if (kDebugMode) {
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

    final firestore = FirebaseFirestore.instance;
    firestore.useFirestoreEmulator('localhost', 8080);
    // firestore.settings = firestore.settings.copyWith(persistenceEnabled: false);
  }
  // var logger = Logger();
  // List<FeedItem> lista = await getFeedItems();
  // logger.d(lista[0].user.imageUrl);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UgmaNet',
        theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color.fromARGB(255, 33, 72, 243)),
        home: const SignInPage2());
  }
}
