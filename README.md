# Flow

A Flutter application tracks hydration intake and toilet habits with a Wear OS integration.

## 🛠 Configuration

This project uses environment variables to manage configurations for different environments (
Development and Production).

### Create Environment Files

Create two files in the root directory of your project:

* `.env.dev` (for local development)
* `.env.prd` (for production/release)

### Add Credentials

Populate both files with your Supabase credentials:

**`.env.dev`**

```properties
SUPABASE_URL=your_dev_supabase_url
SUPABASE_ANON_KEY=your_dev_anon_key
```

## 🚀 Building & Running

### Run in Development

To run the app on an emulator or connected watch using the **development** configuration:

```bash
flutter run --dart-define=ENV=dev
```

### Build for Release (APK)

To generate an optimized release APK for installation on physical watches.
This command splits the APK by ABI (architecture) to drastically reduce the file size, which is
critical for wearable devices with limited storage.

```bash
flutter build apk --split-per-abi --dart-define=ENV=prd
```

#### Command Breakdown

- **--split-per-abi:** Generates separate APKs for armeabi-v7a (older watches) and arm64-v8a (newer
  watches) instead of one giant universal file.
- **--dart-define=ENV=prd:** Passes the ENV variable to the Dart compiler, instructing the app to
  load
  secrets from .env.prd.

#### Output Location

After building, the APKs will be located in: build/app/outputs/apk/release/