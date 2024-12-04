import 'package:UgmaNet/services/user_service.dart';
import 'package:UgmaNet/visual/Screens/Home.dart';
import 'package:UgmaNet/visual/Screens/Loader.dart';
import 'package:UgmaNet/visual/Screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});
  final _userService = UserServiceImpl.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserStatus>(
      stream: _userService.authChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoaderScreen();
        }

        if (snapshot.data?.user == null) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/logo/UGMA-LOGO.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Bienvenido a UGMAnet, por favor ingresa!')
                    : const Text('Bienvenido a UGMAnet, por favor regístrate!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Al iniciar sesión, aceptas nuestros términos y condiciones.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          );

        } else if (snapshot.data?.profile == null) {
          return const CreateProfileScreen();
        } else if (snapshot.data?.user != null && snapshot.data?.profile != null) {
          return const HomeScreen();
        }
        FirebaseAuth.instance.signOut();
        return const Scaffold(body: Text('Ocurrio un error al intentar cargar la app. Por favor, vuelve a iniciar sesión'),);
      },
    );
  }
}