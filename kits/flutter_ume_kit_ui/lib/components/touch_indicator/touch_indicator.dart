part of '../../flutter_ume_kit_ui_plus.dart';

class TouchIndicator extends StatelessWidget
    implements PluggableWithNestedWidget {
  const TouchIndicator({Key? key}) : super(key: key);

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'TouchIndicator';

  @override
  String get displayName => 'TouchIndicator';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(iconBytesWithTouchIndicator);

  @override
  Widget buildNestedWidget(Widget child) {
    return ti.TouchIndicator(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
