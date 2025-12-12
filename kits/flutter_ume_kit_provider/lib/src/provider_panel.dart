part of '../flutter_ume_kit_provider_plus.dart';

/// Provider state viewer panel for flutter_ume
class ProviderPanel extends StatefulWidget implements Pluggable {
  const ProviderPanel({super.key});

  @override
  State<ProviderPanel> createState() => _ProviderPanelState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(_iconBytes);

  @override
  String get name => 'Provider';

  @override
  String get displayName => 'Provider';

  @override
  void onTrigger() {}
}

class _ProviderPanelState extends State<ProviderPanel> {
  List<ProviderNode> _providers = [];
  List<ProviderNode> _filteredProviders = [];
  ProviderNode? _selectedProvider;
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showSearch = false;
  String? _error;
  bool _showDetail = false; // 用于窄屏时控制显示详情页

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Connect to VM Service first
      final connected = await VmServiceHelper.instance.connect();
      if (!connected) {
        debugPrint('ProviderPanel: VM Service not available, using fallback');
      }

      await _loadProviders();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);

    try {
      // Try VM Service eval first
      var providers = await ProviderScanner.scanViaEval();

      // Fallback to direct binding access
      if (providers.isEmpty) {
        debugPrint('ProviderPanel: Falling back to direct binding access');
        providers = ProviderScanner.scanFromBinding();
      }

      setState(() {
        _providers = providers;
        _filteredProviders = providers;
        _isLoading = false;

        // Keep selection if possible
        if (_selectedProvider != null) {
          _selectedProvider = providers.firstWhereOrNull(
            (p) => p.id == _selectedProvider!.id,
          );
        }

        // Auto-select first if none selected
        if (_selectedProvider == null && providers.isNotEmpty) {
          _selectedProvider = providers.first;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProviders = _providers;
      } else {
        _filteredProviders = _providers
            .where((p) => p.type.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectProvider(ProviderNode provider, {bool showDetail = false}) {
    setState(() {
      _selectedProvider = provider;
      _showDetail = showDetail;
    });
  }

  void _goBackToList() {
    setState(() => _showDetail = false);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      contentWidget: _buildContent(),
      toolbarActions: [
        Tuple3(
          'Search',
          const Icon(Icons.search, size: 20),
          () => setState(() => _showSearch = !_showSearch),
        ),
        Tuple3(
          'Refresh',
          const Icon(Icons.refresh, size: 20),
          _loadProviders,
        ),
      ],
      closeAction: UMEWidget.closeActivatedPlugin,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initAndLoad,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 宽屏（>600）使用双列布局，窄屏使用单列
        final isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen) {
          return _buildWideLayout();
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }

  /// 宽屏双列布局
  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _ProviderListWidget(
            providers: _filteredProviders,
            selectedProvider: _selectedProvider,
            onSelect: (p) => _selectProvider(p),
            showSearch: _showSearch,
            searchQuery: _searchQuery,
            onFilter: _filter,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _InstanceViewerWidget(
            provider: _selectedProvider,
          ),
        ),
      ],
    );
  }

  /// 窄屏单列布局
  Widget _buildNarrowLayout() {
    // 显示详情页
    if (_showDetail && _selectedProvider != null) {
      return Column(
        children: [
          _buildDetailHeader(),
          Expanded(
            child: _InstanceViewerWidget(
              provider: _selectedProvider,
            ),
          ),
        ],
      );
    }

    // 显示列表
    return _ProviderListWidget(
      providers: _filteredProviders,
      selectedProvider: _selectedProvider,
      onSelect: (p) => _selectProvider(p, showDetail: true),
      showSearch: _showSearch,
      searchQuery: _searchQuery,
      onFilter: _filter,
    );
  }

  /// 详情页顶部导航栏
  Widget _buildDetailHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: _goBackToList,
            tooltip: 'Back to list',
          ),
          Expanded(
            child: Text(
              _selectedProvider?.type ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
