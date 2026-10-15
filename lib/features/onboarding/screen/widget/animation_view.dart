import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class DriverAnimation extends StatelessWidget {
  const DriverAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset("assets/lottie/onboarding_animation.json",width:400,height: 600 );
  }
}
