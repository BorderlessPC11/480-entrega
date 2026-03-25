# borderless_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase (Authentication)

1. Create a project in the [Firebase Console](https://console.firebase.google.com) and enable **Authentication → Sign-in method → Email/Password**.
2. From the app root, install the FlutterFire CLI and generate `lib/firebase_options.dart` plus platform config.

Activate the CLI once:

```bash
dart pub global activate flutterfire_cli
```

Run **`configure`** using one of these (the bare `flutterfire` command only works if Pub’s global `bin` is on your `PATH`):

**Option A — works without changing PATH (recommended):**

```bash
cd borderless_app
dart pub global run flutterfire_cli:flutterfire configure
```

**Option B — short command after adding Pub to your PATH (macOS/Linux):**

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
flutterfire configure
```

On Apple Silicon, `pub-cache` is often under `~/.pub-cache`.

3. Replace the placeholder [`lib/firebase_options.dart`](lib/firebase_options.dart) with the generated file (or run the command above so it overwrites it).

Until Firebase is configured, `Firebase.initializeApp` may fail at runtime on a device or simulator.
