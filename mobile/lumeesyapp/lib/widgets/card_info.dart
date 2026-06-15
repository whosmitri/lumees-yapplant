import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String texto;

  const InfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 65,

      decoration: BoxDecoration(
        color: AppTheme.mainIvory,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              icon,
              size: 36,
              color: iconColor,
            ),
          ),

          Expanded(
            child: Text(
              texto,
              style: AppTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}