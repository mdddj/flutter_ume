part of '../flutter_ume_kit_shared_preferences_plus.dart';

/// Represents a SharedPreferences entry with key, value and type info
class SharedPreferencesEntry {
  final String key;
  final Object? value;
  final SharedPreferencesType type;

  const SharedPreferencesEntry({
    required this.key,
    required this.value,
    required this.type,
  });

  String get valueAsString {
    if (value == null) return 'null';
    if (type == SharedPreferencesType.stringList) {
      final list = value as List<String>;
      return list.join(', ');
    }
    return value.toString();
  }

  String get typeLabel => type.label;
}

enum SharedPreferencesType {
  string('String'),
  int('int'),
  double('double'),
  bool('bool'),
  stringList('List<String>');

  final String label;
  const SharedPreferencesType(this.label);
}
