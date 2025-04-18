# MytilEX App

MytilEX is a Flutter application for forecasting water and mussel quality in aquaculture.
Developed by University Of Naples "Parthenope"

---

## Requirements

- [Flutter SDK 3.x](https://docs.flutter.dev/get-started/install)
- Android Studio or Visual Studio Code
- Java 17 (required for Android builds)
- A modern browser (for web builds)
- Xcode (for iOS builds)

---

## Initial Setup

Clone the repository:

```bash
git clone https://github.com/uniparthenope/MytilEX.git
cd MytilEX
```

Fetch the dependencies:

```bash
flutter pub get
```

---

## Android

### Requirements

- Java 17
- Active emulator or phisical device

### Check Java version

```bash
java -version
```

It must be at least:
```
openjdk version "17"
```

If necessary, manually set Java 17:

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$PATH"
```

### Launch app

```bash
flutter run -d android
```

---
## iOS

### Requirements
- macOS with Xcode installed

- CocoaPods (brew install cocoapods if needed)

- A physical iOS device or Simulator

### Setup
```bash
cd ios
pod install
cd ..
```
### Launch app
```bash
flutter run -d ios
```


## Browser

### Requirements

- Google Chrome, Edge or newer browsers

### Launch app

```bash
flutter run -d chrome
```

Or:

```bash
flutter run -d web-server
```

> A local server will be started, accessible from `http://localhost:8000` or similar.
---

## Check available Devices

```bash
flutter devices
```

To list all available devices/emulators/browsers.