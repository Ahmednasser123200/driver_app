import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';


class InformationCard extends StatelessWidget {
  final String image;
  final String title;
  final String address;
  final ThemeData theme;

  const InformationCard({super.key, 
    required this.image,
    required this.title,
    required this.address,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0,0), // changes position of shadow
            ),
          ]

      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(image)),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.black,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(color: AppColors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
