part of '../../flutter_ume_kit_device_plus.dart';

class CpuInfoPage extends StatefulWidget implements Pluggable {
  const CpuInfoPage(
      {super.key, this.child, this.platform = const LocalPlatform()});

  final Platform platform;

  final Widget? child;

  @override
  _CpuInfoPageState createState() => _CpuInfoPageState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'CPUInfo';

  @override
  String get displayName => 'CPUInfo';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(iconBytesCpu);
}

class _CpuInfoPageState extends State<CpuInfoPage> {
  var _deviceInfo = <Map<String, String>>[];

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      contentWidget: AnimatedSwitcher(
        duration: Duration(milliseconds: 223),
        child: !widget.platform.isAndroid
            ? Container(
                color: Colors.white,
                child: Center(
                  child: Text('Only available on Android device'),
                ),
              )
            : ListView.separated(
                itemBuilder: (ctx, index) => ListTile(
                      title: Text(_deviceInfo[index].keys.first),
                      trailing: Text(_deviceInfo[index].values.first),
                    ),
                separatorBuilder: (ctx, index) => Divider(),
                itemCount: _deviceInfo.length),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.platform.isAndroid) _setupData();
  }

  void _setupData() {
    const int megabyte = 1024 * 1024;
    final deviceInfo = <Map<String, String>>[];
    deviceInfo.addAll([
      {'Kernel architecture': '${SysInfo.kernelArchitecture}'},
      {'Kernel bitness': '${SysInfo.kernelBitness}'},
      {'Kernel name': SysInfo.kernelName},
      {'Kernel version': SysInfo.kernelVersion},
      {'Operating system name': SysInfo.operatingSystemName},
      {'Operating system ': SysInfo.operatingSystemVersion},
      {'User directory': SysInfo.userDirectory},
      {'User id': SysInfo.userId},
      {'User name': SysInfo.userName},
      {'User space bitness': '${SysInfo.userSpaceBitness}'},
      {
        'Total physical memory':
            '${SysInfo.getTotalPhysicalMemory() ~/ megabyte} MB'
      },
      {
        'Free physical memory':
            '${SysInfo.getFreePhysicalMemory() ~/ megabyte} MB'
      },
      {
        'Total virtual memory':
            '${SysInfo.getTotalVirtualMemory() ~/ megabyte} MB'
      },
      {
        'Free virtual memory':
            '${SysInfo.getFreeVirtualMemory() ~/ megabyte} MB'
      },
      {
        'Virtual memory size':
            '${SysInfo.getVirtualMemorySize() ~/ megabyte} MB'
      },
    ]);

    final processors = SysInfo.cores;
    deviceInfo.add(
      {'Number of processors': '${processors.length}'},
    );
    for (var processor in processors) {
      deviceInfo.addAll([
        {
          '[${processors.indexOf(processor)}] Architecture':
              '${processor.architecture}'
        },
        {'[${processors.indexOf(processor)}] Name': processor.name},
        {'[${processors.indexOf(processor)}] Socket': '${processor.socket}'},
        {'[${processors.indexOf(processor)}] Vendor': processor.vendor},
      ]);
    }
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _deviceInfo = deviceInfo;
      });
    });
  }
}
