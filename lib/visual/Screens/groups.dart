import 'package:flutter/material.dart';

class GroupsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child:
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.group_outlined),
        SizedBox(width: 8,),
        Text('No perteneces a ningún grupo aún')
      ],
    ),
    );
  }

  const GroupsTab({super.key});
}