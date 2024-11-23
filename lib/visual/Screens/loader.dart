import 'package:flutter/material.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          direction: Axis.vertical, children: [
          Image(image: AssetImage('assets/images/logo/UGMA-LOGO.png'), height: 128, width: 128,),
          SizedBox(height: 10,),
          CircularProgressIndicator(),
        ],),
      )
    );
  }
}