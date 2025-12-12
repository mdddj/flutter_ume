part of '../../flutter_ume_kit_device_plus.dart';

class DeviceInfoPanel extends StatefulWidget implements Pluggable {
  final Platform platform;

  const DeviceInfoPanel({super.key, this.platform = const LocalPlatform()});

  @override
  _DeviceInfoPanelState createState() => _DeviceInfoPanelState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(iconBytes);

  @override
  String get name => 'DeviceInfo';

  @override
  String get displayName => 'DeviceInfo';

  @override
  void onTrigger() {}
}

class _DeviceInfoPanelState extends State<DeviceInfoPanel> {
  Map<String, dynamic> _deviceData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  void _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> dataMap = {};

    if (widget.platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      dataMap = {
        'Brand': info.brand,
        'Model': info.model,
        'Device': info.device,
        'Android Version': info.version.release,
        'SDK': info.version.sdkInt,
        'Hardware': info.hardware,
        'Manufacturer': info.manufacturer,
        'Physical Device': info.isPhysicalDevice,
        'Board': info.board,
        'Display': info.display,
        'Fingerprint': info.fingerprint,
        'Host': info.host,
        'ID': info.id,
        'Product': info.product,
        'Tags': info.tags,
        'Type': info.type,
        'Bootloader': info.bootloader,
        'Security Patch': info.version.securityPatch,
        'Base OS': info.version.baseOS,
        'Codename': info.version.codename,
        'Supported ABIs': info.supportedAbis.join(', '),
      };
    } else if (widget.platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      dataMap = {
        'Name': info.name,
        'Model': info.model,
        'System': info.systemName,
        'Version': info.systemVersion,
        'Physical Device': info.isPhysicalDevice,
        'Identifier': info.identifierForVendor,
        'Machine': info.utsname.machine,
        'Sysname': info.utsname.sysname,
        'Nodename': info.utsname.nodename,
        'Release': info.utsname.release,
      };
    }

    setState(() {
      _deviceData = dataMap;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      contentWidget: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _deviceData.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              itemBuilder: (context, index) {
                final key = _deviceData.keys.elementAt(index);
                final value = _deviceData[key];
                return _InfoRow(label: key, value: '$value');
              },
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
