import 'package:UgmaNet/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:UgmaNet/visual/Screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var logger = Logger();
  List<FeedItem> lista = await getFeedItems();
  logger.d(lista[0].user.imageUrl);
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
