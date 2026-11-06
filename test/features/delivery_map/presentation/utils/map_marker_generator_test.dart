import 'package:driver_app/features/delivery_map/presentation/utils/map_marker_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    MapMarkerGenerator.clearCache();
    MapMarkerGenerator.maxCacheSize = MapMarkerGenerator.defaultMaxCacheSize;
  });

  group('MapMarkerGenerator', () {
    test('createPillMarker caches results by (label, icon, colors)', () async {
      expect(MapMarkerGenerator.cacheSize, 0);

      final first = await MapMarkerGenerator.createPillMarker(
        label: 'Your location',
        icon: Icons.navigation_rounded,
      );
      expect(MapMarkerGenerator.cacheSize, 1);

      final cached = MapMarkerGenerator.getCachedPillMarker(
        label: 'Your location',
        icon: Icons.navigation_rounded,
      );
      expect(cached, same(first));

      final second = await MapMarkerGenerator.createPillMarker(
        label: 'Your location',
        icon: Icons.navigation_rounded,
      );
      expect(second, same(first));
      expect(MapMarkerGenerator.cacheSize, 1);
    });

    test('enforces maxCacheSize limit with LRU eviction', () async {
      MapMarkerGenerator.maxCacheSize = 2;

      await MapMarkerGenerator.createPillMarker(
        label: 'Marker 1',
        icon: Icons.navigation_rounded,
      );
      await MapMarkerGenerator.createPillMarker(
        label: 'Marker 2',
        icon: Icons.local_florist_rounded,
      );
      expect(MapMarkerGenerator.cacheSize, 2);

      // Refresh Marker 1 so Marker 2 becomes least recently used
      MapMarkerGenerator.getCachedPillMarker(
        label: 'Marker 1',
        icon: Icons.navigation_rounded,
      );

      // Adding Marker 3 evicts Marker 2
      await MapMarkerGenerator.createPillMarker(
        label: 'Marker 3',
        icon: Icons.person_rounded,
      );
      expect(MapMarkerGenerator.cacheSize, 2);

      expect(
        MapMarkerGenerator.getCachedPillMarker(
          label: 'Marker 1',
          icon: Icons.navigation_rounded,
        ),
        isNotNull,
      );
      expect(
        MapMarkerGenerator.getCachedPillMarker(
          label: 'Marker 2',
          icon: Icons.local_florist_rounded,
        ),
        isNull,
      );
    });

    test('rasterizes pill marker on canvas when forceRasterizeInTests is true', () async {
      MapMarkerGenerator.forceRasterizeInTests = true;
      addTearDown(() => MapMarkerGenerator.forceRasterizeInTests = false);

      final descriptor = await MapMarkerGenerator.createPillMarker(
        label: 'Canvas Pill',
        icon: Icons.local_florist_rounded,
      );
      expect(descriptor, isNotNull);
    });
  });
}
