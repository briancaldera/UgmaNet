import 'package:UgmaNet/models/profile.dart';
import 'package:UgmaNet/services/user_service.dart';
import 'package:UgmaNet/visual/Screens/Loader.dart';
import 'package:UgmaNet/visual/Screens/feed.dart';
import 'package:UgmaNet/visual/Screens/profile.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

TextEditingController nameTextController = TextEditingController();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserServiceImpl.instance;

  @override
  Widget build(BuildContext context) {
    final future = _checkProfile();

    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoaderScreen();
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null) {
              // Pide al usuario crear su perfil
              Navigator.of(context).push(MaterialPageRoute<CreateProfileScreen>(
                  builder: (context) => CreateProfileScreen()));
              return const Center();
            } else {
              return DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/icons/minilogo.png',
                          width: 32,
                          height: 32,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            'UGMAnet',
                            style:
                                TextStyle(fontSize: 18, color: Colors.indigo),
                          ),
                        )
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<ProfileScreen>(
                              builder: (context) => ProfileScreen(
                                appBar: AppBar(
                                  title: const Text('Perfil de usuario'),
                                ),
                                actions: [
                                  SignedOutAction((context) {
                                    Navigator.of(context).pop();
                                  })
                                ],
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute<
                                                    UpdateProfilePictureScreen>(
                                                builder: (context) =>
                                                    const UpdateProfilePictureScreen()));
                                      },
                                      child: const Text('Cambiar foto'))
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                    automaticallyImplyLeading: false,
                  ),
                  bottomNavigationBar: const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.home_outlined)),
                      Tab(icon: Icon(Icons.group_outlined)),
                      Tab(icon: Icon(Icons.notifications_outlined)),
                    ],
                  ),
                  body: const TabBarView(
                    children: [
                      NewsFeedTab(),
                      Icon(Icons.group_outlined),
                      Icon(Icons.notifications_outlined),
                    ],
                  ),
                ),
              );
            }
          }
        });
  }

  Future<Profile?> _checkProfile() async {
    final user = await _userService.getCurrentUser();

    final profile = await _userService.getProfile(user!.uid);
    return profile;
  }
}
