import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onTap;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: glowColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.6),
              blurRadius: 12.0,
              spreadRadius: 1.0,
            ),
            BoxShadow(
              color: glowColor.withOpacity(0.3),
              blurRadius: 24.0,
              spreadRadius: 8.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: glowColor,
              size: 48.0,
            ),
            const SizedBox(height: 12.0),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
