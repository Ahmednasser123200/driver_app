import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver_app/core/constants/app_images/app_images.dart';
import 'package:driver_app/features/order_history/presentation/view/widgets/common/avatar_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
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
}
