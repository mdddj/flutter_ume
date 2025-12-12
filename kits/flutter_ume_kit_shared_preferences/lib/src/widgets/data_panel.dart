part of '../../flutter_ume_kit_shared_preferences_plus.dart';

class _DataPanelWidget extends StatefulWidget {
  final SharedPreferencesEntry? entry;
  final Future<void> Function(String key) onDelete;
  final Future<void> Function(
      String key, Object value, SharedPreferencesType type) onUpdate;
  final ValueChanged<bool>? onEditingChanged;

  const _DataPanelWidget({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.onUpdate,
    this.onEditingChanged,
  });

  @override
  State<_DataPanelWidget> createState() => _DataPanelWidgetState();
}

class _DataPanelWidgetState extends State<_DataPanelWidget> {
  bool _isEditing = false;
  bool _confirmDelete = false;
  late TextEditingController _controller;
  bool? _boolValue;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _initEditValue();
  }

  @override
  void didUpdateWidget(covariant _DataPanelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry?.key != widget.entry?.key) {
      if (_isEditing) {
        _setEditing(false);
      }
      _confirmDelete = false;
      _error = null;
      _initEditValue();
    }
  }

  void _initEditValue() {
    if (widget.entry == null) return;
    if (widget.entry!.type == SharedPreferencesType.bool) {
      _boolValue = widget.entry!.value as bool?;
      _controller.text = '';
    } else if (widget.entry!.type == SharedPreferencesType.stringList) {
      final list = widget.entry!.value as List<String>?;
      _controller.text = list?.join('\n') ?? '';
    } else {
      _controller.text = widget.entry!.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Object? _parseValue() {
    final text = _controller.text;
    try {
      switch (widget.entry!.type) {
        case SharedPreferencesType.string:
          return text;
        case SharedPreferencesType.int:
          return int.parse(text);
        case SharedPreferencesType.double:
          return double.parse(text);
        case SharedPreferencesType.bool:
          return _boolValue;
        case SharedPreferencesType.stringList:
          return text.split('\n').where((s) => s.isNotEmpty).toList();
      }
    } catch (e) {
      return null;
    }
  }

  void _setEditing(bool editing) {
    setState(() => _isEditing = editing);
    widget.onEditingChanged?.call(editing);
  }

  void _save() async {
    final value = _parseValue();
    if (value == null) {
      setState(() => _error = 'Invalid value');
      return;
    }
    _setEditing(false);
    setState(() => _error = null);
    await widget.onUpdate(widget.entry!.key, value, widget.entry!.type);
  }

  void _cancelEdit() {
    _setEditing(false);
    setState(() => _error = null);
    _initEditValue();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entry == null) {
      return const Center(
        child: Text('Select a key to view details',
            style: TextStyle(color: Colors.grey)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                Text(widget.entry!.key,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(widget.entry!.typeLabel,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (_confirmDelete) ...[
            const Text('Delete?',
                style: TextStyle(fontSize: 12, color: Colors.red)),
            const SizedBox(width: 8),
            _ActionButton(
                icon: Icons.check,
                label: 'Yes',
                color: Colors.red,
                onTap: () {
                  widget.onDelete(widget.entry!.key);
                  setState(() => _confirmDelete = false);
                }),
            const SizedBox(width: 4),
            _ActionButton(
                icon: Icons.close,
                label: 'No',
                onTap: () {
                  setState(() => _confirmDelete = false);
                }),
          ] else if (_isEditing) ...[
            _ActionButton(icon: Icons.save, label: 'Save', onTap: _save),
            const SizedBox(width: 4),
            _ActionButton(
                icon: Icons.close,
                label: 'Cancel',
                color: Colors.grey,
                onTap: _cancelEdit),
          ] else ...[
            _ActionButton(
                icon: Icons.edit,
                label: 'Edit',
                onTap: () {
                  _initEditValue();
                  _setEditing(true);
                }),
            const SizedBox(width: 4),
            _ActionButton(
                icon: Icons.delete,
                label: 'Delete',
                color: Colors.red,
                onTap: () {
                  setState(() => _confirmDelete = true);
                }),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isEditing) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            if (widget.entry!.type == SharedPreferencesType.bool)
              Row(
                children: [
                  const Text('Value: ', style: TextStyle(fontSize: 13)),
                  ChoiceChip(
                    label: const Text('true'),
                    selected: _boolValue == true,
                    onSelected: (_) => setState(() => _boolValue = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('false'),
                    selected: _boolValue == false,
                    onSelected: (_) => setState(() => _boolValue = false),
                  ),
                ],
              )
            else
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  hintText:
                      widget.entry!.type == SharedPreferencesType.stringList
                          ? 'One item per line'
                          : 'Enter value',
                ),
                maxLines: widget.entry!.type == SharedPreferencesType.stringList
                    ? 5
                    : 1,
                style: const TextStyle(fontSize: 13),
                onChanged: (_) => setState(() => _error = null),
              ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SelectableText(
          widget.entry!.valueAsString,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? Colors.blue),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(fontSize: 11, color: color ?? Colors.blue)),
          ],
        ),
      ),
    );
  }
}
