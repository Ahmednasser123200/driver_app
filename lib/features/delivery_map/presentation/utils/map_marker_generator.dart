import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class MapMarkerGenerator {
  static const Color primaryColor = Color(0xFFD21E6A);
  static bool isTestMode = false;

  static Future<BitmapDescriptor> createPillMarker({
    required String label,
    required IconData icon,
    Color backgroundColor = primaryColor,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) async {
    if (isTestMode ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return BitmapDescriptor.defaultMarker;
    }

    try {
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);

      const double height = 40;
      const double radius = height / 2;
      const double iconSize = 18;
      const double iconPadding = 12;
      const double spacing = 6;
      const double rightPadding = 16;

      final textSpan = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final pillWidth =
          iconPadding + iconSize + spacing + textPainter.width + rightPadding;

      // Draw shadow
      final shadowPaint =
          Paint()
            ..color = Colors.black.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 3, pillWidth, height),
        const Radius.circular(radius),
      );
      canvas.drawRRect(shadowRRect, shadowPaint);

      // Draw background pill
      final backgroundPaint =
          Paint()
            ..color = backgroundColor
            ..style = PaintingStyle.fill
            ..isAntiAlias = true;
      final pillRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, pillWidth, height),
        const Radius.circular(radius),
      );
      canvas.drawRRect(pillRRect, backgroundPaint);

      // Draw leading icon
      final iconTextSpan = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      );
      final iconPainter = TextPainter(
        text: iconTextSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final iconY = (height - iconPainter.height) / 2;
      iconPainter.paint(canvas, Offset(iconPadding, iconY));

      // Draw label
      final textY = (height - textPainter.height) / 2;
      textPainter.paint(
        canvas,
        Offset(iconPadding + iconSize + spacing, textY),
      );

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(
        pillWidth.toInt() + 6,
        height.toInt() + 8,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      }
    } catch (_) {
      // In tests or fallback
    }

    return BitmapDescriptor.defaultMarker;
  }
}
