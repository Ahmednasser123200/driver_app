# driver_app

A new Flutter project.

## Google Maps setup (Android)

Enable the **Maps SDK for Android** for a Google Cloud project and create an API
key restricted to this app's Android application ID and signing certificate.
Add the key to the ignored `android/local.properties` file:

```properties
MAPS_API_KEY=your-restricted-key
```

The Android build passes this local value to the Maps SDK manifest entry. Do
not commit `android/local.properties` or put an unrestricted API key in source
control. Rebuild the app after adding or changing the key.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
