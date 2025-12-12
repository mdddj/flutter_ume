part of '../../flutter_ume_kit_ui_plus.dart';

class WidgetDetailInspector extends StatelessWidget implements Pluggable {
  const WidgetDetailInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      home: const _DetailPage(),
    );
  }

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(iconBytesWithDetailInspector);

  @override
  String get name => 'WidgetDetail';

  @override
  String get displayName => 'WidgetDetail';

  @override
  void onTrigger() {}
}

class _DetailPage extends StatefulWidget {
  const _DetailPage();

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<_DetailPage> with WidgetsBindingObserver {
  _DetailPageState() : selection = WidgetInspectorService.instance.selection;

  Offset? _lastPointerLocation;

  final InspectorSelection selection;

  void _inspectAt(Offset? position) {
    final List<RenderObject> selected = HitTest.hitTest(position);
    setState(() {
      selection.candidates = selected;
    });
  }

  void _handlePanDown(DragDownDetails event) {
    _lastPointerLocation = event.globalPosition;
    _inspectAt(event.globalPosition);
  }

  void _handleTap() {
    if (_lastPointerLocation != null) {
      _inspectAt(_lastPointerLocation);
    }
    final nav = Navigator.of(context);
    Future.delayed(const Duration(milliseconds: 100), () {
      nav.push(MaterialPageRoute(builder: (ctx) {
        return _InfoPage(
            elements: selection.currentElement!.debugGetDiagnosticChain());
      }));
    });
  }

  @override
  void initState() {
    super.initState();
    selection.clear();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    GestureDetector gesture = GestureDetector(
      onTap: _handleTap,
      onPanDown: _handlePanDown,
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height),
      ),
    );
    children.add(gesture);
    children.add(InspectorOverlay(
        selection: selection, needDescription: false, needEdges: false));
    return Stack(textDirection: TextDirection.ltr, children: children);
  }
}

class _DetailModel {
  List<int> colors = [
    Random().nextInt(256),
    Random().nextInt(256),
    Random().nextInt(256)
  ];
  Element element;
  _DetailModel(this.element);
}

class _InfoPage extends StatefulWidget {
  const _InfoPage({required this.elements});

  final List<Element> elements;

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<_InfoPage> {
  late final List<_DetailModel> _originalList;
  List<_DetailModel> _filteredList = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _originalList =
        widget.elements.map(_DetailModel.new).toList(growable: false);
    _filteredList = _originalList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() => _filteredList = _originalList);
      return;
    }
    final regExp = RegExp(trimmed, caseSensitive: false);
    setState(() {
      _filteredList = _originalList
          .where((m) => regExp.hasMatch(m.element.widget.toStringShort()))
          .toList();
    });
  }

  void _navigateToDetail(_DetailModel model) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DetailPage2(element: model.element),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Text(
              'Build Chain',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.elements.length}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '搜索 Widget...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // 列表
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final model = _filteredList[index];
                final depth = _originalList.indexOf(model);
                return _WidgetCard(
                  model: model,
                  depth: depth,
                  onTap: () => _navigateToDetail(model),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetCard extends StatelessWidget {
  const _WidgetCard({
    required this.model,
    required this.depth,
    required this.onTap,
  });

  final _DetailModel model;
  final int depth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final widgetName = model.element.widget.toStringShort();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 深度指示器
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Color.fromARGB(
                    40,
                    model.colors[0],
                    model.colors[1],
                    model.colors[2],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$depth',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(
                        255,
                        model.colors[0],
                        model.colors[1],
                        model.colors[2],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Widget 名称
              Expanded(
                child: Text(
                  widgetName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailPage2 extends StatelessWidget {
  const _DetailPage2({required this.element});

  final Element element;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          element.widget.toStringShort(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _DetailContent(element: element),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.element});

  final Element element;

  @override
  Widget build(BuildContext context) {
    final widget = element.widget;
    final renderObject = element.renderObject;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Widget 基本信息
        _InfoCard(
          title: 'Widget',
          icon: Icons.widgets_outlined,
          color: Colors.blue,
          children: [
            _InfoRow('Type', widget.runtimeType.toString()),
            if (widget.key != null) _InfoRow('Key', widget.key.toString()),
            _InfoRow('HashCode', '0x${widget.hashCode.toRadixString(16)}'),
          ],
        ),
        const SizedBox(height: 12),

        // RenderObject 信息
        if (renderObject != null) ...[
          _InfoCard(
            title: 'RenderObject',
            icon: Icons.layers_outlined,
            color: Colors.orange,
            children: [
              _InfoRow('Type', renderObject.runtimeType.toString()),
              if (renderObject is RenderBox && renderObject.hasSize)
                _InfoRow(
                  'Size',
                  '${renderObject.size.width.toStringAsFixed(1)} × ${renderObject.size.height.toStringAsFixed(1)}',
                ),
              _InfoRow('Attached', renderObject.attached ? 'Yes' : 'No'),
              _InfoRow(
                  'Needs Paint', renderObject.debugNeedsPaint ? 'Yes' : 'No'),
              _InfoRow(
                  'Needs Layout', renderObject.debugNeedsLayout ? 'Yes' : 'No'),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // 约束信息
        if (renderObject is RenderBox) ...[
          _InfoCard(
            title: 'Constraints',
            icon: Icons.straighten_outlined,
            color: Colors.green,
            children: [
              if (renderObject.hasSize) ...[
                _InfoRow('Min Width',
                    renderObject.constraints.minWidth.toStringAsFixed(1)),
                _InfoRow('Max Width',
                    renderObject.constraints.maxWidth.toStringAsFixed(1)),
                _InfoRow('Min Height',
                    renderObject.constraints.minHeight.toStringAsFixed(1)),
                _InfoRow('Max Height',
                    renderObject.constraints.maxHeight.toStringAsFixed(1)),
              ],
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Widget 属性
        _InfoCard(
          title: 'Widget Properties',
          icon: Icons.code_outlined,
          color: Colors.purple,
          expandable: true,
          children: [
            _CodeBlock(content: _formatWidgetProperties(widget)),
          ],
        ),
        const SizedBox(height: 12),

        // RenderObject 详情
        if (renderObject != null)
          _InfoCard(
            title: 'RenderObject Details',
            icon: Icons.description_outlined,
            color: Colors.teal,
            expandable: true,
            children: [
              _CodeBlock(content: renderObject.toStringDeep()),
            ],
          ),
      ],
    );
  }

  String _formatWidgetProperties(Widget widget) {
    final description = widget.toStringDeep();
    // 简单格式化，移除多余空行
    return description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .join('\n');
  }
}

class _InfoCard extends StatefulWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
    this.expandable = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  final bool expandable;

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          InkWell(
            onTap: widget.expandable
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(widget.icon, size: 16, color: widget.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.expandable)
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          // 内容
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          content,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade800,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
