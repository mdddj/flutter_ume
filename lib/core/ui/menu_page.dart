part of '../../flutter_ume_plus.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, this.action, this.minimalAction, this.closeAction});

  final MenuAction? action;
  final MinimalAction? minimalAction;
  final CloseAction? closeAction;

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final PluginStoreManager _storeManager = PluginStoreManager();

  List<Pluggable?> _dataList = [];

  @override
  void initState() {
    super.initState();
    _handleData();
  }

  void _handleData() async {
    List<Pluggable?> dataList = [];
    List<String>? list = await _storeManager.fetchStorePlugins();
    if (list == null || list.isEmpty) {
      dataList = PluginManager.instance.pluginsMap.values.toList();
    } else {
      for (var f in list) {
        bool contain = PluginManager.instance.pluginsMap.containsKey(f);
        if (contain) {
          dataList.add(PluginManager.instance.pluginsMap[f]);
        }
      }
      for (var key in PluginManager.instance.pluginsMap.keys) {
        if (!list.contains(key)) {
          dataList.add(PluginManager.instance.pluginsMap[key]);
        }
      }
    }
    _saveData(dataList);
    setState(() {
      _dataList = dataList;
    });
  }

  void _saveData(List<Pluggable?> data) {
    List l = data.map((f) => f!.name).toList();
    if (l.isEmpty) {
      return;
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      _storeManager.storePlugins(l as List<String>);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: Colors.white,
              height: 105,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(left: 16, right: 16),
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            if (widget.closeAction != null) {
                              widget.closeAction!();
                            }
                          },
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xffff5a52),
                          )),
                      const SizedBox(
                        width: 8,
                      ),
                      InkWell(
                          onTap: () {
                            if (widget.minimalAction != null) {
                              widget.minimalAction!();
                            }
                          },
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xffe6c029),
                          )),
                    ],
                  ),
                  const Text('UME',
                      style: TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff454545))),
                ],
              ),
            ),
            Expanded(
                child: _dataList.isEmpty
                    ? _EmptyPlaceholder()
                    : DragableGridView(
                        _dataList,
                        childAspectRatio: 0.85,
                        canAccept: (oldIndex, newIndex) {
                          return true;
                        },
                        dragCompletion: (dataList) {
                          _saveData(dataList as List<Pluggable?>);
                        },
                        itemBuilder: (context, dynamic data) {
                          return GestureDetector(
                            onTap: () {
                              widget.action!(data);
                              PluggableMessageService().resetCounter(data);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: _MenuCell(pluginData: data),
                          );
                        },
                      ))
          ],
        ),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Empty'),
    );
  }
}

class _MenuCell extends StatelessWidget {
  const _MenuCell({this.pluginData});

  final Pluggable? pluginData;

  @override
  Widget build(BuildContext context) {
    final Color lineColor = Colors.grey.withOpacity(0.25);
    return LayoutBuilder(builder: (_, constraints) {
      return Material(
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
                left: 0,
                top: 0,
                child: Container(
                    height: constraints.maxHeight,
                    width: 0.5,
                    color: lineColor)),
            Positioned(
                left: 0,
                top: 0,
                child: Container(
                    height: 0.5,
                    width: constraints.maxWidth,
                    color: lineColor)),
            Positioned(
                top: 0,
                right: 0,
                child: Container(
                    height: constraints.maxHeight,
                    width: 0.5,
                    color: lineColor)),
            Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                    height: 0.5,
                    width: constraints.maxWidth,
                    color: lineColor)),
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 40,
                      width: 40,
                      child: IconCache.icon(pluggableInfo: pluginData!)),
                  Container(
                      margin: const EdgeInsets.only(top: 25),
                      child: Text(pluginData!.displayName,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black)))
                ],
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: RedDot(
                pluginDatas: [pluginData],
                size: 22,
              ),
            ),
          ],
        ),
      );
    });
  }
}
