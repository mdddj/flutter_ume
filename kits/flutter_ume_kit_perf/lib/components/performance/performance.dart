part of '../../flutter_ume_kit_perf_plus.dart';

class Performance extends StatelessWidget implements Pluggable {
  const Performance({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: 20),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: PerformanceOverlay.allEnabled()));
  }

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(iconBytes);

  @override
  String get name => 'PerfOverlay';

  @override
  String get displayName => 'PerfOverlay';

  @override
  void onTrigger() {}
}
