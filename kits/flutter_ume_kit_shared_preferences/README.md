# flutter_ume_kit_shared_preferences_plus

SharedPreferences viewer and editor kit for flutter_ume.

## Features

- View all SharedPreferences keys and values
- Search/filter keys
- Edit values (String, int, double, bool, List<String>)
- Delete keys
- Refresh data

## Usage

```dart
import 'package:flutter_ume_plus/flutter_ume_plus.dart';
import 'package:flutter_ume_kit_shared_preferences_plus/flutter_ume_kit_shared_preferences_plus.dart';

void main() {
  PluginManager.instance
    ..register(SharedPreferencesPanel());
  
  runApp(
    UMEWidget(
      child: MyApp(),
      enable: true,
    ),
  );
}
```
