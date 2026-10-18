import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class DriverAnimation extends StatelessWidget {
  const DriverAnimation({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });
  final double? width;
  final double? height;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      "assets/lottie/onboarding_animation.json",
      width: width,
      height: height,
      fit: fit,
    );
  }
}
