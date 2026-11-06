import 'dart:collection';
import 'dart:ui' as ui;

import 'package:driver_app/core/themes/app_colors/app_colors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class _MarkerCacheKey extends Equatable {
  final String label;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final int backgroundColorValue;
  final int textColorValue;
  final int iconColorValue;

  const _MarkerCacheKey({
    required this.label,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.iconFontPackage,
    required this.backgroundColorValue,
    required this.textColorValue,
    required this.iconColorValue,
  });

  @override
  List<Object?> get props => [
        label,
        iconCodePoint,
        iconFontFamily,
        iconFontPackage,
        backgroundColorValue,
        textColorValue,
        iconColorValue,
      ];
}

abstract final class MapMarkerGenerator {
  static const Color primaryColor = AppColors.primary;
  static const int defaultMaxCacheSize = 20;
  static int maxCacheSize = defaultMaxCacheSize;
  static bool forceRasterizeInTests = false;

  static final LinkedHashMap<_MarkerCacheKey, BitmapDescriptor> _cache =
      LinkedHashMap<_MarkerCacheKey, BitmapDescriptor>();
  static final Map<_MarkerCacheKey, Future<BitmapDescriptor>> _inFlight =
      <_MarkerCacheKey, Future<BitmapDescriptor>>{};

  static int get cacheSize => _cache.length;

  static void clearCache() {
    _cache.clear();
    _inFlight.clear();
  }

  static _MarkerCacheKey _buildKey({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return _MarkerCacheKey(
      label: label,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      iconFontPackage: icon.fontPackage,
      backgroundColorValue: backgroundColor.toARGB32(),
      textColorValue: textColor.toARGB32(),
      iconColorValue: iconColor.toARGB32(),
    );
  }

  static void _putInCache(_MarkerCacheKey key, BitmapDescriptor descriptor) {
    if (maxCacheSize <= 0) return;

    _cache.remove(key);
    while (_cache.length >= maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = descriptor;
  }

  /// Synchronously retrieves a cached [BitmapDescriptor] if already generated.
  static BitmapDescriptor? getCachedPillMarker({
    required String label,
    required IconData icon,
    Color backgroundColor = primaryColor,
    Color textColor = AppColors.white,
    Color iconColor = AppColors.white,
  }) {
    final key = _buildKey(
      label: label,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
    );
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
    }
    return cached;
  }

  static Future<BitmapDescriptor> createPillMarker({
    required String label,
    required IconData icon,
    Color backgroundColor = primaryColor,
    Color textColor = AppColors.white,
    Color iconColor = AppColors.white,
  }) async {
    final key = _buildKey(
      label: label,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
    );

    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return cached;
    }

    final pending = _inFlight[key];
    if (pending != null) {
      return pending;
    }

    final future = _rasterizePillMarker(
      label: label,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
    );
    _inFlight[key] = future;

    try {
      final descriptor = await future;
      _putInCache(key, descriptor);
      return descriptor;
    } finally {
      _inFlight.remove(key);
    }
  }

  static Future<BitmapDescriptor> _rasterizePillMarker({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
  }) async {
    if (!forceRasterizeInTests &&
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
        style: TextStyle(
          color: textColor,
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
      final shadowPaint = Paint()
        ..color = AppColors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final shadowRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 3, pillWidth, height),
        const Radius.circular(radius),
      );
      canvas.drawRRect(shadowRRect, shadowPaint);

      // Draw background pill
      final backgroundPaint = Paint()
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
      // Fallback when canvas rasterization is unavailable
    }

    return BitmapDescriptor.defaultMarker;
  }
}
