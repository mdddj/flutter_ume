part of '../../flutter_ume_kit_provider_plus.dart';

// Colors for different value types (matching DevTools style)
const _typeColor = Color(0xFF4EC9B0);
const _boolColor = Color(0xFF569CD6);
const _nullColor = Color(0xFF569CD6);
const _numColor = Color(0xFFB5CEA8);
const _stringColor = Color(0xFFCE9178);
const _keyColor = Color(0xFF9CDCFE);

/// Wrapper for local values when VM Service is not available
class _LocalValue {
  final dynamic value;
  const _LocalValue(this.value);
}

class _InstanceViewerWidget extends StatefulWidget {
  final ProviderNode? provider;

  const _InstanceViewerWidget({required this.provider});

  @override
  State<_InstanceViewerWidget> createState() => _InstanceViewerWidgetState();
}

class _InstanceViewerWidgetState extends State<_InstanceViewerWidget> {
  InstanceDetails? _details;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void didUpdateWidget(covariant _InstanceViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider?.id != widget.provider?.id) {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    if (widget.provider == null) {
      setState(() {
        _details = null;
        _error = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      InstanceDetails? details;

      // Try VM Service first
      if (VmServiceHelper.instance.isAvailable) {
        // If we have a valueRef, use it to get details via VM Service
        if (widget.provider!.valueRef != null) {
          details = await VmServiceHelper.instance
              .getInstanceDetails(widget.provider!.valueRef!);
        }

        // Fallback: try to get value ref again
        if (details == null) {
          final valueRef = await VmServiceHelper.instance
              .getProviderValueRef(widget.provider!.id);
          if (valueRef != null) {
            details =
                await VmServiceHelper.instance.getInstanceDetails(valueRef);
          }
        }
      }

      // Fallback: use local value if VM Service is not available
      if (details == null && widget.provider!.value != null) {
        details = _createLocalInstanceDetails(widget.provider!.value!);
      }

      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to local value on error
      if (widget.provider!.value != null) {
        final details = _createLocalInstanceDetails(widget.provider!.value!);
        if (mounted) {
          setState(() {
            _details = details;
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Create InstanceDetails from a local Dart object (fallback when VM Service is not available)
  InstanceDetails _createLocalInstanceDetails(Object value) {
    if (value is bool) {
      return InstanceDetails.boolean(value.toString(), instanceRefId: '');
    }
    if (value is num) {
      return InstanceDetails.number(value.toString(), instanceRefId: '');
    }
    if (value is String) {
      return InstanceDetails.string(value, instanceRefId: '');
    }
    if (value is List) {
      return InstanceDetails.list(
        length: value.length,
        instanceRefId: '',
        elements: value.map((e) => _LocalValue(e)).toList(),
      );
    }
    if (value is Map) {
      return InstanceDetails.map(
        length: value.length,
        instanceRefId: '',
        associations: null, // Can't convert to MapAssociation easily
      );
    }

    // For complex objects, create an ObjectInstance with basic info
    return InstanceDetails.object(
      type: value.runtimeType.toString(),
      instanceRefId: '',
      fields: _extractLocalFields(value),
    );
  }

  /// Extract fields from a local object using common patterns
  List<ObjectField> _extractLocalFields(Object value) {
    final fields = <ObjectField>[];

    // Try toJson
    try {
      final dynamic obj = value;
      final json = obj.toJson();
      if (json is Map) {
        for (final entry in json.entries) {
          fields.add(ObjectField(
            name: entry.key.toString(),
            value: _LocalValue(entry.value),
          ));
        }
        return fields;
      }
    } catch (_) {}

    // Try toMap
    try {
      final dynamic obj = value;
      final map = obj.toMap();
      if (map is Map) {
        for (final entry in map.entries) {
          fields.add(ObjectField(
            name: entry.key.toString(),
            value: _LocalValue(entry.value),
          ));
        }
        return fields;
      }
    } catch (_) {}

    // Try common getters
    final dynamic obj = value;
    final getters = [
      'value',
      'state',
      'data',
      'items',
      'list',
      'count',
      'length',
      'isLoading',
      'error',
      'message',
      'status',
      'result',
      'id',
      'name'
    ];

    for (final getter in getters) {
      try {
        dynamic val;
        switch (getter) {
          case 'value':
            val = obj.value;
            break;
          case 'state':
            val = obj.state;
            break;
          case 'data':
            val = obj.data;
            break;
          case 'items':
            val = obj.items;
            break;
          case 'list':
            val = obj.list;
            break;
          case 'count':
            val = obj.count;
            break;
          case 'length':
            val = obj.length;
            break;
          case 'isLoading':
            val = obj.isLoading;
            break;
          case 'error':
            val = obj.error;
            break;
          case 'message':
            val = obj.message;
            break;
          case 'status':
            val = obj.status;
            break;
          case 'result':
            val = obj.result;
            break;
          case 'id':
            val = obj.id;
            break;
          case 'name':
            val = obj.name;
            break;
        }
        if (val != null) {
          fields.add(ObjectField(name: getter, value: _LocalValue(val)));
        }
      } catch (_) {}
    }

    return fields;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.provider == null) {
      return const Center(
        child: Text(
          'Select a provider to view its state',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.provider!.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _typeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${widget.provider!.id}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: _loadDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
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
          child: Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_details == null) {
      return const Center(
        child: Text(
          'Unable to load value',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: _InstanceDetailsView(
        details: _details!,
        isRoot: true,
      ),
    );
  }
}

/// View for displaying InstanceDetails
class _InstanceDetailsView extends StatefulWidget {
  final InstanceDetails details;
  final bool isRoot;
  final int depth;

  const _InstanceDetailsView({
    required this.details,
    this.isRoot = false,
    this.depth = 0,
  });

  @override
  State<_InstanceDetailsView> createState() => _InstanceDetailsViewState();
}

class _InstanceDetailsViewState extends State<_InstanceDetailsView> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isRoot || widget.depth < 1;
  }

  void _toggleExpand() {
    if (widget.details.isExpandable) {
      setState(() => _isExpanded = !_isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;

    return switch (details) {
      NullInstance() => _buildSimpleValue('null', _nullColor),
      BoolInstance(:final displayString) =>
        _buildSimpleValue(displayString, _boolColor),
      NumInstance(:final displayString) =>
        _buildSimpleValue(displayString, _numColor),
      StringInstance(:final displayString) =>
        _buildSimpleValue('"$displayString"', _stringColor),
      EnumInstance(:final type, :final value) =>
        _buildSimpleValue('$type.$value', _typeColor),
      ListInstance() => _buildListView(details),
      MapInstance() => _buildMapView(details),
      ObjectInstance() => _buildObjectView(details),
    };
  }

  Widget _buildSimpleValue(String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.depth * 16.0,
        top: 2,
        bottom: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(ListInstance list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableHeader('List(${list.length})'),
        if (_isExpanded) _buildListChildren(list),
      ],
    );
  }

  Widget _buildListChildren(ListInstance list) {
    final elements = list.elements;
    if (elements == null || elements.isEmpty) {
      return _buildEmptyMessage('[]');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < elements.length && i < 100; i++)
          _InstanceRefView(
            ref: elements[i],
            fieldName: '[$i]',
            depth: widget.depth + 1,
          ),
        if (elements.length > 100)
          Padding(
            padding: EdgeInsets.only(left: (widget.depth + 1) * 16.0 + 20),
            child: Text(
              '... ${elements.length - 100} more items',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildMapView(MapInstance map) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableHeader('Map(${map.length})'),
        if (_isExpanded) _buildMapChildren(map),
      ],
    );
  }

  Widget _buildMapChildren(MapInstance map) {
    final associations = map.associations;
    if (associations == null || associations.isEmpty) {
      return _buildEmptyMessage('{}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < associations.length && i < 100; i++)
          _MapEntryView(
            association: associations[i],
            depth: widget.depth + 1,
          ),
        if (associations.length > 100)
          Padding(
            padding: EdgeInsets.only(left: (widget.depth + 1) * 16.0 + 20),
            child: Text(
              '... ${associations.length - 100} more entries',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildObjectView(ObjectInstance obj) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableHeader(obj.type),
        if (_isExpanded) _buildObjectChildren(obj),
      ],
    );
  }

  Widget _buildObjectChildren(ObjectInstance obj) {
    if (obj.fields.isEmpty) {
      return _buildEmptyMessage('No fields');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in obj.fields)
          _ObjectFieldView(
            field: field,
            depth: widget.depth + 1,
          ),
      ],
    );
  }

  Widget _buildExpandableHeader(String typeDisplay) {
    return InkWell(
      onTap: _toggleExpand,
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.depth * 16.0,
          top: 2,
          bottom: 2,
        ),
        child: Row(
          children: [
            if (widget.details.isExpandable)
              Icon(
                _isExpanded ? Icons.expand_more : Icons.chevron_right,
                size: 16,
                color: Colors.grey.shade600,
              )
            else
              const SizedBox(width: 16),
            Text(
              typeDisplay,
              style: const TextStyle(color: _typeColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Padding(
      padding: EdgeInsets.only(left: (widget.depth + 1) * 16.0 + 20),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }
}

/// View for an InstanceRef that needs to be resolved
class _InstanceRefView extends StatefulWidget {
  final dynamic ref;
  final String fieldName;
  final int depth;

  const _InstanceRefView({
    required this.ref,
    required this.fieldName,
    required this.depth,
  });

  @override
  State<_InstanceRefView> createState() => _InstanceRefViewState();
}

class _InstanceRefViewState extends State<_InstanceRefView> {
  InstanceDetails? _details;
  bool _isLoading = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ref = widget.ref;

    // Handle _LocalValue (fallback when VM Service is not available)
    if (ref is _LocalValue) {
      return _buildLocalValue(ref.value);
    }

    // Handle InstanceRef
    if (ref is vm.InstanceRef) {
      return _buildRefView(ref);
    }

    // Handle Sentinel
    if (ref is vm.Sentinel) {
      return _buildSimpleValue(
          '<${ref.valueAsString ?? "sentinel"}>', Colors.grey);
    }

    // Handle null
    if (ref == null) {
      return _buildSimpleValue('null', _nullColor);
    }

    // Fallback
    return _buildSimpleValue(ref.toString(), Colors.grey.shade700);
  }

  Widget _buildLocalValue(dynamic value) {
    if (value == null) {
      return _buildSimpleValue('null', _nullColor);
    }
    if (value is bool) {
      return _buildSimpleValue(value.toString(), _boolColor);
    }
    if (value is num) {
      return _buildSimpleValue(value.toString(), _numColor);
    }
    if (value is String) {
      return _buildSimpleValue('"$value"', _stringColor);
    }
    if (value is List) {
      return _buildExpandableLocal('List(${value.length})', value);
    }
    if (value is Map) {
      return _buildExpandableLocal('Map(${value.length})', value);
    }
    // Complex object - show type and toString
    return _buildExpandableLocal(value.runtimeType.toString(), value);
  }

  Widget _buildExpandableLocal(String typeDisplay, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.depth * 16.0,
              top: 2,
              bottom: 2,
            ),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                Flexible(
                  child: Text(
                    '${widget.fieldName}: ',
                    style: const TextStyle(color: _keyColor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    typeDisplay,
                    style: const TextStyle(color: _typeColor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) _buildLocalChildren(value),
      ],
    );
  }

  Widget _buildLocalChildren(dynamic value) {
    if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < value.length && i < 100; i++)
            _InstanceRefView(
              ref: _LocalValue(value[i]),
              fieldName: '[$i]',
              depth: widget.depth + 1,
            ),
        ],
      );
    }
    if (value is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in value.entries.take(100))
            _InstanceRefView(
              ref: _LocalValue(entry.value),
              fieldName: '"${entry.key}"',
              depth: widget.depth + 1,
            ),
        ],
      );
    }
    // For complex objects, just show toString
    return Padding(
      padding: EdgeInsets.only(left: (widget.depth + 1) * 16.0 + 20),
      child: SelectableText(
        value.toString(),
        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
      ),
    );
  }

  Widget _buildRefView(vm.InstanceRef ref) {
    // Handle primitive types inline
    switch (ref.kind) {
      case vm.InstanceKind.kNull:
        return _buildSimpleValue('null', _nullColor);
      case vm.InstanceKind.kBool:
        return _buildSimpleValue(ref.valueAsString ?? 'false', _boolColor);
      case vm.InstanceKind.kInt:
      case vm.InstanceKind.kDouble:
        return _buildSimpleValue(ref.valueAsString ?? '0', _numColor);
      case vm.InstanceKind.kString:
        return _buildSimpleValue('"${ref.valueAsString ?? ""}"', _stringColor);
      default:
        return _buildExpandableRef(ref);
    }
  }

  Widget _buildExpandableRef(vm.InstanceRef ref) {
    final typeDisplay = _getTypeDisplay(ref);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggleExpand,
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.depth * 16.0,
              top: 2,
              bottom: 2,
            ),
            child: Row(
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Icon(
                    _isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                Flexible(
                  child: Text(
                    '${widget.fieldName}: ',
                    style: const TextStyle(color: _keyColor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    typeDisplay,
                    style: const TextStyle(color: _typeColor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded && _details != null)
          _InstanceDetailsView(
            details: _details!,
            depth: widget.depth + 1,
          ),
      ],
    );
  }

  String _getTypeDisplay(vm.InstanceRef ref) {
    if (ref.kind == vm.InstanceKind.kList) {
      return 'List(${ref.length ?? 0})';
    }
    if (ref.kind == vm.InstanceKind.kMap) {
      return 'Map(${ref.length ?? 0})';
    }
    return ref.classRef?.name ?? 'Object';
  }

  Future<void> _toggleExpand() async {
    if (_isExpanded) {
      setState(() => _isExpanded = false);
      return;
    }

    if (_details != null) {
      setState(() => _isExpanded = true);
      return;
    }

    // Load details
    final ref = widget.ref;
    if (ref is! vm.InstanceRef) return;

    setState(() => _isLoading = true);

    try {
      final details = await VmServiceHelper.instance.getInstanceDetails(ref);
      if (mounted) {
        setState(() {
          _details = details;
          _isExpanded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSimpleValue(String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.depth * 16.0,
        top: 2,
        bottom: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              '${widget.fieldName}: ',
              style: const TextStyle(color: _keyColor, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// View for a map entry
class _MapEntryView extends StatefulWidget {
  final vm.MapAssociation association;
  final int depth;

  const _MapEntryView({
    required this.association,
    required this.depth,
  });

  @override
  State<_MapEntryView> createState() => _MapEntryViewState();
}

class _MapEntryViewState extends State<_MapEntryView> {
  @override
  Widget build(BuildContext context) {
    final key = widget.association.key;
    final value = widget.association.value;

    String keyStr;
    if (key is vm.InstanceRef) {
      keyStr = key.valueAsString ?? key.classRef?.name ?? 'key';
      if (key.kind == vm.InstanceKind.kString) {
        keyStr = '"$keyStr"';
      }
    } else {
      keyStr = key?.toString() ?? 'null';
    }

    return _InstanceRefView(
      ref: value,
      fieldName: keyStr,
      depth: widget.depth,
    );
  }
}

/// View for an object field
class _ObjectFieldView extends StatefulWidget {
  final ObjectField field;
  final int depth;

  const _ObjectFieldView({
    required this.field,
    required this.depth,
  });

  @override
  State<_ObjectFieldView> createState() => _ObjectFieldViewState();
}

class _ObjectFieldViewState extends State<_ObjectFieldView> {
  InstanceDetails? _details;
  bool _isLoading = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final value = field.value;

    // Handle _LocalValue (fallback when VM Service is not available)
    if (value is _LocalValue) {
      return _buildLocalValue(value.value);
    }

    // Handle InstanceRef
    if (value is vm.InstanceRef) {
      return _buildRefView(value);
    }

    // Handle Sentinel
    if (value is vm.Sentinel) {
      return _buildSimpleValue(
          '<${value.valueAsString ?? "sentinel"}>', Colors.grey);
    }

    // Handle null
    if (value == null) {
      return _buildSimpleValue('null', _nullColor);
    }

    // Fallback
    return _buildSimpleValue(value.toString(), Colors.grey.shade700);
  }

  Widget _buildLocalValue(dynamic value) {
    final field = widget.field;
    if (value == null) {
      return _buildSimpleValue('null', _nullColor);
    }
    if (value is bool) {
      return _buildSimpleValue(value.toString(), _boolColor);
    }
    if (value is num) {
      return _buildSimpleValue(value.toString(), _numColor);
    }
    if (value is String) {
      return _buildSimpleValue('"$value"', _stringColor);
    }
    if (value is List) {
      return _buildExpandableLocal(field.name, 'List(${value.length})', value);
    }
    if (value is Map) {
      return _buildExpandableLocal(field.name, 'Map(${value.length})', value);
    }
    // Complex object
    return _buildExpandableLocal(
        field.name, value.runtimeType.toString(), value);
  }

  Widget _buildExpandableLocal(
      String fieldName, String typeDisplay, dynamic value) {
    final field = widget.field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.depth * 16.0,
              top: 2,
              bottom: 2,
            ),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                if (field.isFinal)
                  Text(
                    'final ',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                Flexible(
                  child: Text(
                    '$fieldName: ',
                    style: const TextStyle(color: _keyColor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    typeDisplay,
                    style: const TextStyle(color: _typeColor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) _buildLocalChildren(value),
      ],
    );
  }

  Widget _buildLocalChildren(dynamic value) {
    if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < value.length && i < 100; i++)
            _InstanceRefView(
              ref: _LocalValue(value[i]),
              fieldName: '[$i]',
              depth: widget.depth + 1,
            ),
        ],
      );
    }
    if (value is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in value.entries.take(100))
            _InstanceRefView(
              ref: _LocalValue(entry.value),
              fieldName: '"${entry.key}"',
              depth: widget.depth + 1,
            ),
        ],
      );
    }
    // For complex objects, just show toString
    return Padding(
      padding: EdgeInsets.only(left: (widget.depth + 1) * 16.0 + 20),
      child: SelectableText(
        value.toString(),
        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
      ),
    );
  }

  Widget _buildRefView(vm.InstanceRef ref) {
    // Handle primitive types inline
    switch (ref.kind) {
      case vm.InstanceKind.kNull:
        return _buildSimpleValue('null', _nullColor);
      case vm.InstanceKind.kBool:
        return _buildSimpleValue(ref.valueAsString ?? 'false', _boolColor);
      case vm.InstanceKind.kInt:
      case vm.InstanceKind.kDouble:
        return _buildSimpleValue(ref.valueAsString ?? '0', _numColor);
      case vm.InstanceKind.kString:
        return _buildSimpleValue('"${ref.valueAsString ?? ""}"', _stringColor);
      default:
        return _buildExpandableRef(ref);
    }
  }

  Widget _buildExpandableRef(vm.InstanceRef ref) {
    final typeDisplay = _getTypeDisplay(ref);
    final field = widget.field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggleExpand,
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.depth * 16.0,
              top: 2,
              bottom: 2,
            ),
            child: Row(
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Icon(
                    _isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                if (field.isFinal)
                  Text(
                    'final ',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                Flexible(
                  child: Text(
                    '${field.name}: ',
                    style: const TextStyle(color: _keyColor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    typeDisplay,
                    style: const TextStyle(color: _typeColor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded && _details != null)
          _InstanceDetailsView(
            details: _details!,
            depth: widget.depth + 1,
          ),
      ],
    );
  }

  String _getTypeDisplay(vm.InstanceRef ref) {
    if (ref.kind == vm.InstanceKind.kList) {
      return 'List(${ref.length ?? 0})';
    }
    if (ref.kind == vm.InstanceKind.kMap) {
      return 'Map(${ref.length ?? 0})';
    }
    return ref.classRef?.name ?? 'Object';
  }

  Future<void> _toggleExpand() async {
    if (_isExpanded) {
      setState(() => _isExpanded = false);
      return;
    }

    if (_details != null) {
      setState(() => _isExpanded = true);
      return;
    }

    // Load details
    final ref = widget.field.ref;
    if (ref == null) return;

    setState(() => _isLoading = true);

    try {
      final details = await VmServiceHelper.instance.getInstanceDetails(ref);
      if (mounted) {
        setState(() {
          _details = details;
          _isExpanded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSimpleValue(String value, Color color) {
    final field = widget.field;

    return Padding(
      padding: EdgeInsets.only(
        left: widget.depth * 16.0,
        top: 2,
        bottom: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  if (field.isFinal)
                    TextSpan(
                      text: 'final ',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  TextSpan(
                    text: '${field.name}: ',
                    style: const TextStyle(color: _keyColor, fontSize: 13),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(color: color, fontSize: 13),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
