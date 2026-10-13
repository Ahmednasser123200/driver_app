import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GoPackButton extends StatelessWidget {
  const GoPackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(backgroundColor: AppColors.primary,
    child: Icon(Icons.arrow_back,color: AppColors.background, ),);
  }
}