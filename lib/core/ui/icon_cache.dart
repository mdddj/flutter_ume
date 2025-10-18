part of '../../flutter_ume_plus.dart';

class IconCache {
  static final Map<String, Widget> _icons = Map();
  static Widget? icon({
    required Pluggable pluggableInfo,
  }) {
    if (!_icons.containsKey(pluggableInfo.name)) {
      final i = Image(image: pluggableInfo.iconImageProvider);
      _icons.putIfAbsent(pluggableInfo.name, () => i);
    } else if (!_icons.containsKey(pluggableInfo.name)) {
      return Container();
    }
    return _icons[pluggableInfo.name];
  }
}
