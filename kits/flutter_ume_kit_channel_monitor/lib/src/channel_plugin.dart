part of '../flutter_ume_kit_channel_monitor_plus.dart';
class ChannelPlugin extends Pluggable {
  ChannelPlugin() {
    ChannelBinding.ensureInitialized();
  }

  @override
  Widget buildWidget(BuildContext? context) {
    return const ChannelPages();
  }

  @override
  String get displayName => 'Channel Monitor';

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(iconData));

  @override
  String get name => 'Channel Monitor';

  @override
  void onTrigger() {}
}
