
import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const WorkoutCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Text(title, style: TextStyle(fontSize: 20.0)),
        ),
      ),
    );
  }
}
