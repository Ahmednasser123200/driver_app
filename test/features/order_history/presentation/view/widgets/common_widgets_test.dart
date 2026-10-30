import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver_app/core/constants/app_images/app_images.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('SectionTitle', () {
    testWidgets('renders title text', (tester) async {
      await pumpApp(tester, const SectionTitle(text: 'Test Title'));
      expect(find.text('Test Title'), findsOneWidget);
    });
  });

  group('FieldLabel', () {
    testWidgets('renders label text', (tester) async {
      await pumpApp(tester, const FieldLabel(text: 'Label Text'));
      expect(find.text('Label Text'), findsOneWidget);
    });
  });

  group('InfoCard', () {
    testWidgets('renders child widget', (tester) async {
      await pumpApp(tester, const InfoCard(child: Text('Card Content')));
      expect(find.text('Card Content'), findsOneWidget);
    });
  });

  group('CenteredScrollView', () {
    testWidgets('renders child in scroll view', (tester) async {
      await pumpApp(
        tester,
        const CenteredScrollView(child: Text('Centered Content')),
      );
      expect(find.text('Centered Content'), findsOneWidget);
    });
  });

  group('AvatarImage', () {
    testWidgets('uses the fallback asset when the url is null', (tester) async {
      await pumpApp(tester, const AvatarImage(imageUrl: null));

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, AppImages.defaultAvatar);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('uses the fallback asset when the url is empty', (tester) async {
      await pumpApp(tester, const AvatarImage(imageUrl: ''));

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, AppImages.defaultAvatar);
    });

    testWidgets('uses CachedNetworkImage when url is provided', (tester) async {
      await pumpApp(
        tester,
        const AvatarImage(imageUrl: 'http://example.com/avatar.png'),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}
