part of '../../flutter_ume_kit_channel_monitor_plus.dart';

class ChannelBinding extends WidgetsFlutterBinding {
  static WidgetsBinding? ensureInitialized() {
    ChannelBinding();
    return WidgetsBinding.instance;
  }

  @override
  // 替换 BinaryMessenger
  BinaryMessenger createBinaryMessenger() {
    return UmeBinaryMessenger.binaryMessenger;
  }
}
