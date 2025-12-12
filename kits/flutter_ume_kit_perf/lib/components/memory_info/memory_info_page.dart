part of '../../flutter_ume_kit_perf_plus.dart';

class MemoryInfoPage extends StatelessWidget implements Pluggable {
  const MemoryInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(contentWidget: _MemoryWidget());
  }

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(iconBytes2);

  @override
  String get name => 'MemoryInfo';

  @override
  String get displayName => 'MemoryInfo';

  @override
  void onTrigger() {}
}

class _DetailModel {
  final int? count;
  final String? classId;
  final String? className;

  _DetailModel(this.count, this.classId, this.className);
}

class _MemoryWidget extends StatefulWidget {
  const _MemoryWidget();

  @override
  _MemoryWidgetState createState() => _MemoryWidgetState();
}

class _MemoryWidgetState extends State<_MemoryWidget> {
  final MemoryService _memoryservice = MemoryService();
  int _sortColumnIndex = 0;
  bool _checked = true;
  _DetailModel? _selectedDetail;

  @override
  void initState() {
    super.initState();
    _memoryservice.getInfos(() => setState(() {}));
  }

  void _hidePrivateClass(bool? check) {
    _checked = check ?? true;
    _memoryservice.hidePrivateClasses(_checked);
    setState(() {});
  }

  void _enterDetailPage(_DetailModel detail) {
    setState(() => _selectedDetail = detail);
  }

  void _goBack() {
    setState(() => _selectedDetail = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedDetail != null) {
      return _buildDetailView();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildTableHeader()),
          _buildSliverList(),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: Text(_selectedDetail!.className ?? '',
            style: const TextStyle(fontSize: 16)),
      ),
      body: _MemoryDetail(detail: _selectedDetail!, service: _memoryservice),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('VM Info', _memoryservice.vmInfo, Icons.memory),
          const SizedBox(height: 12),
          _buildInfoSection(
              'Memory', _memoryservice.memoryUseage, Icons.pie_chart),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _hidePrivateClass(!_checked),
            child: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: _checked,
                    onChanged: _hidePrivateClass,
                    activeColor: const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Hide private class',
                    style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2196F3)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF999999))),
              const SizedBox(height: 2),
              Text(content,
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF333333))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF2196F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          _buildSortButton('Size', 0),
          _buildSortButton('Count', 1),
          const Expanded(
              flex: 2,
              child: Text('Class',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildSortButton(String title, int index) {
    final isSelected = _sortColumnIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _memoryservice.sort(
            index == 0
                ? (d) => d.accumulatedSize
                : (d) => d.instancesAccumulated,
            true,
            () => setState(() => _sortColumnIndex = index),
          );
        },
        child: Row(
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            if (isSelected)
              const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            final stats = _memoryservice.infoList[index];
            final isLast = index == _memoryservice.infoList.length - 1;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(12))
                    : null,
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _enterDetailPage(_DetailModel(
                      stats.instancesAccumulated,
                      stats.classRef!.id,
                      stats.classRef!.name,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                                  _memoryservice
                                      .byteToString(stats.accumulatedSize!),
                                  style: const TextStyle(fontSize: 13))),
                          Expanded(
                              child: Text('${stats.instancesAccumulated}',
                                  style: const TextStyle(fontSize: 13))),
                          Expanded(
                              flex: 2,
                              child: Text('${stats.classRef!.name}',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.chevron_right,
                              size: 18, color: Color(0xFFCCCCCC)),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ),
            );
          },
          childCount: _memoryservice.infoList.length,
        ),
      ),
    );
  }
}

class _MemoryDetail extends StatefulWidget {
  const _MemoryDetail({required this.detail, required this.service});

  final _DetailModel detail;
  final MemoryService service;

  @override
  __MemoryDetailState createState() => __MemoryDetailState();
}

class __MemoryDetailState extends State<_MemoryDetail> {
  String _properties = '';
  String _functions = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.service.getClassDetailInfo(widget.detail.classId!, (info) {
      _properties = info?.propeties?.map((e) => e.propertyStr).join('\n') ?? '';
      _functions = info?.functions?.join('\n') ?? '';
      _loading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_properties.isEmpty && _functions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('The Object is Sentinel',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_properties.isNotEmpty)
            _buildSection('Properties', _properties, Icons.list_alt),
          if (_functions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection('Functions', _functions, Icons.functions),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2196F3)),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 20),
          Text(content,
              style: const TextStyle(
                  fontSize: 13, height: 1.6, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
