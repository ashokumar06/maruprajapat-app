# Maru Prajapat (com.avirastra.maruprajapat)

A new Flutter project.

## App Name & Package Information

- **App Name**: Maru Prajapat
- **Package Name**: `com.avirastra.maruprajapat`

## Environment Setup (.env)

This project uses the `flutter_dotenv` package to load environment variables automatically.

1. Create a `.env` file in the root directory (you can copy from `.env.example`).
2. Populate the required variables (e.g., API_URL, Firebase tokens, Cloudflare R2 tokens).
3. The app automatically loads the `.env` file at startup in `lib/config/env_config.dart`.

## App Signing & Keystore (JKS)

The keystore (`upload-keystore.jks`) has been generated and is located in the `android/app/` directory.

### Import/Setup Key Configuration

To build release versions, ensure you have a `key.properties` file inside the `android/` directory. Create `android/key.properties` with the following content (update passwords if needed):

```properties
storePassword=maruprajapat123
keyPassword=maruprajapat123
keyAlias=upload
storeFile=upload-keystore.jks
```

This is automatically picked up by `android/app/build.gradle.kts` to sign your APK/AppBundle.

## Generating a Product Build

Run the following commands from the root of your project to generate signed builds for production:

### 1. Build Android AppBundle (Recommended for Play Store)

```bash
flutter build appbundle --release
```

The output file will be generated at `build/app/outputs/bundle/release/app-release.aab`.

### 2. Build Android APK

```bash
flutter build apk --release
```

The output file will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

## Getting Started

This project is a starting point for a Flutter application.
A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
