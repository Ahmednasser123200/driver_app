import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driver_app/features/auth/presentation/apply/view/widgets/apply_file_upload_field.dart';

void main() {
  testWidgets('renders hint when filePath is null or empty', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApplyFileUploadField(
            label: 'License',
            hint: 'Upload License',
            filePath: null,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('License'), findsOneWidget);
    expect(find.text('Upload License'), findsOneWidget);

    await tester.tap(find.byType(ApplyFileUploadField));
    expect(tapped, isTrue);
  });

  testWidgets('renders file basename when filePath is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ApplyFileUploadField(
            label: 'License',
            hint: 'Upload License',
            filePath: '/var/data/license_photo.jpg',
            onTap: _dummyTap,
          ),
        ),
      ),
    );

    expect(find.text('license_photo.jpg'), findsOneWidget);
  });
}

void _dummyTap() {}
