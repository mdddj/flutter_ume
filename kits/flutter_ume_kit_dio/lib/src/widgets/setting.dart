part of '../../flutter_ume_kit_dio_plus.dart';

final _configUtil = DioConfigUtil();

class SettingWidget extends StatelessWidget {
  final DioConfig config;
  final ValueChanged<DioConfig> onChanged;
  final bool show;

  const SettingWidget(
      {super.key,
      required this.config,
      required this.onChanged,
      required this.show});

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }
    return AnimatedContainer(
      height: show ? (MediaQuery.of(context).size.height * 0.4) : 0,
      width: double.infinity,
      duration: const Duration(milliseconds: 244),
      child: Card(
        margin: const EdgeInsets.all(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('设置'),
                Row(
                  children: [
                    Switch(
                      value: config.showFullUrl,
                      onChanged: (value) {
                        changeSetting((oldConfig) =>
                            oldConfig.copyWith(showFullUrl: value));
                      },
                    ),
                    const Text('显示完整url')
                  ],
                ),
                Row(
                  children: [
                    Switch(
                      value: config.showCopyButton,
                      onChanged: (value) {
                        changeSetting((oldConfig) =>
                            oldConfig.copyWith(showCopyButton: value));
                      },
                    ),
                    const Text('显示复制功能')
                  ],
                ),
                Row(
                  children: [
                    Switch(
                      value: config.showRequestHeaders,
                      onChanged: (value) {
                        changeSetting((oldConfig) =>
                            oldConfig.copyWith(showRequestHeaders: value));
                      },
                    ),
                    const Text('显示 Request Headers')
                  ],
                ),
                Row(
                  children: [
                    Switch(
                      value: config.showResponseHeaders,
                      onChanged: (value) {
                        changeSetting((oldConfig) =>
                            oldConfig.copyWith(showResponseHeaders: value));
                      },
                    ),
                    const Text('显示 Respose Headers')
                  ],
                ),
                Divider(),
                _ChangeKeys(
                  config: config,
                  onChanged: onChanged,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void changeSetting(DioConfig Function(DioConfig oldConfig) change) {
    final newConfig = change.call(config);
    _configUtil.saveConfig(newConfig);
    onChanged.call(newConfig);
  }
}

///修改复制的 key
class _ChangeKeys extends StatefulWidget {
  final DioConfig config;
  final ValueChanged<DioConfig> onChanged;

  const _ChangeKeys({required this.config, required this.onChanged});

  @override
  State<_ChangeKeys> createState() => _ChangeKeysState();
}

class _ChangeKeysState extends State<_ChangeKeys> {
  DioConfig get config => widget.config;

  late final _ctrl1 = TextEditingController(text: config.urlKey);
  late final _ctrl2 = TextEditingController(text: config.dataKey);
  late final _ctrl3 = TextEditingController(text: config.responseKey);
  late final _ctrl4 = TextEditingController(text: config.methodKey);
  late final _ctrl5 = TextEditingController(text: config.statusKey);
  late final _ctrl6 = TextEditingController(text: config.timestampKey);
  late final _ctrl7 = TextEditingController(text: config.timeKey);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('配置复制全部的key'),
          TextField(
            controller: _ctrl1,
            decoration: const InputDecoration(
              hintText: 'url key',
              labelText: 'url key',
            ),
            onChanged: (value) {
              changeSetting((oldConfig) => oldConfig.copyWith(urlKey: value));
            },
          ),
          TextField(
            controller: _ctrl2,
            decoration: const InputDecoration(
              hintText: 'data key (参数)',
              labelText: 'data key (参数)',
            ),
            onChanged: (value) {
              changeSetting((oldConfig) => oldConfig.copyWith(dataKey: value));
            },
          ),
          TextField(
            controller: _ctrl3,
            decoration: const InputDecoration(
              hintText: 'response key (返回)',
              labelText: 'response key (返回)',
            ),
            onChanged: (value) {
              changeSetting(
                  (oldConfig) => oldConfig.copyWith(responseKey: value));
            },
          ),
          TextField(
            controller: _ctrl4,
            decoration: const InputDecoration(
              hintText: 'method key',
              labelText: 'method key',
            ),
            onChanged: (value) {
              changeSetting(
                  (oldConfig) => oldConfig.copyWith(methodKey: value));
            },
          ),
          TextField(
            controller: _ctrl5,
            decoration: const InputDecoration(
              hintText: 'status key',
              labelText: 'status key',
            ),
            onChanged: (value) {
              changeSetting(
                  (oldConfig) => oldConfig.copyWith(statusKey: value));
            },
          ),
          TextField(
            controller: _ctrl6,
            decoration: const InputDecoration(
              hintText: '时间戳 key',
              labelText: '时间戳 key',
            ),
            onChanged: (value) {
              changeSetting(
                  (oldConfig) => oldConfig.copyWith(timestampKey: value));
            },
          ),
          TextField(
            controller: _ctrl7,
            decoration: const InputDecoration(
              hintText: '请求时间 key',
              labelText: '请求时间 key',
            ),
            onChanged: (value) {
              changeSetting((oldConfig) => oldConfig.copyWith(timeKey: value));
            },
          ),
        ],
      ),
    );
  }

  ///修改配置
  void changeSetting(DioConfig Function(DioConfig oldConfig) change) {
    final newConfig = change.call(config);
    _configUtil.saveConfig(newConfig);
    widget.onChanged.call(newConfig);
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    _ctrl4.dispose();
    _ctrl5.dispose();
    _ctrl6.dispose();
    _ctrl7.dispose();
    super.dispose();
  }
}
