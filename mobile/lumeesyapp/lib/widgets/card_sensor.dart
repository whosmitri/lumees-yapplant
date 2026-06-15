import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SensorCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String titulo;
  final String valor;

  const SensorCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 100,

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
              size: 48,
              color: iconColor,
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  titulo,
                  style: AppTheme.titleSmall,
                ),

                const SizedBox(height: 8),

                Text(
                  valor,
                  style: AppTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}