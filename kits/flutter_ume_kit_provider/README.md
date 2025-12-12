# flutter_ume_kit_provider_plus

Provider state viewer kit for flutter_ume. View and inspect Provider states in your Flutter app.

## Features

- View all Provider instances in your app
- Inspect Provider values with full object field expansion
- Support for nested objects, lists, maps, and enums
- Real-time refresh

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_ume_kit_provider_plus: ^1.0.0
```

## Usage

```dart
import 'package:flutter_ume_plus/flutter_ume_plus.dart';
import 'package:flutter_ume_kit_provider_plus/flutter_ume_kit_provider_plus.dart';

void main() {
  PluginManager.instance
    ..register(ProviderPanel());
  
  runApp(UMEWidget(child: MyApp()));
}
```

## Important: VM Service Configuration

This plugin uses VM Service to inspect Provider values. You **must** run your app with the `--no-dds` flag:

```bash
flutter run --no-dds
```

For real devices, you may also need:

```bash
flutter run --no-dds --vm-service-host=0.0.0.0
```

### IDE Configuration

**VS Code** - Add to `.vscode/launch.json`:
```json
{
  "configurations": [
    {
      "name": "Flutter",
      "type": "dart",
      "request": "launch",
      "args": ["--no-dds"]
    }
  ]
}
```

**Android Studio** - Add `--no-dds` to Run/Debug Configurations > Additional run args

### Why is `--no-dds` required?

DDS (Dart Development Service) is a proxy that can interfere with VM Service connections from within the app. Disabling it allows the plugin to connect directly to VM Service for object inspection.

## Fallback Mode

If VM Service is not available, the plugin will fall back to using `ProviderBinding.debugInstance.providerDetails` directly. This provides basic functionality but with limited object inspection capabilities.

## License

MIT License
