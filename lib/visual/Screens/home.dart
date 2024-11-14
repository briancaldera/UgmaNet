import 'package:UgmaNet/visual/Screens/feed.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

TextEditingController nameTextController = TextEditingController();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(

          title: Row(children: [Image.asset('assets/icons/minilogo.png', width: 32, height: 32,), Padding(padding: EdgeInsets.only(left: 8), child: Text('UGMAnet', style: TextStyle(fontSize: 18, color: Colors.indigo),),)],),
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
                        Form(child: Column(children: [
                          TextFormField(controller: nameTextController, maxLines: 1,
                            decoration: InputDecoration(labelText: 'Nombre'), )
                        ],))
                      ],
                    ),
                  ),
                );
              },
            )
          ],
          automaticallyImplyLeading: false,
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.home_outlined)),
            Tab(icon: Icon(Icons.group_outlined)),
            Tab(icon: Icon(Icons.notifications_outlined)),
          ],
        ),
        body: TabBarView(
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
