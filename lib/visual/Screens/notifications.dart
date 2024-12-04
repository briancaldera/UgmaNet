import 'package:flutter/material.dart';

class NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child:
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_outlined),
        SizedBox(width: 8,),
        Text('No hay notificaciones')
      ],
    ),
    );
  }

  const NotificationsTab({super.key});
}