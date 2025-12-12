part of '../flutter_ume_kit_shared_preferences_plus.dart';

/// SharedPreferences viewer and editor panel for flutter_ume
class SharedPreferencesPanel extends StatefulWidget implements Pluggable {
  const SharedPreferencesPanel({super.key});

  @override
  State<SharedPreferencesPanel> createState() => _SharedPreferencesPanelState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(_iconBytes);

  @override
  String get name => 'SharedPrefs';

  @override
  String get displayName => 'SharedPrefs';

  @override
  void onTrigger() {}
}

class _SharedPreferencesPanelState extends State<SharedPreferencesPanel> {
  List<SharedPreferencesEntry> _entries = [];
  List<SharedPreferencesEntry> _filteredEntries = [];
  SharedPreferencesEntry? _selectedEntry;
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showSearch = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList()..sort();
      final entries = <SharedPreferencesEntry>[];

      for (final key in keys) {
        final value = prefs.get(key);
        final type = _getType(value);
        entries.add(SharedPreferencesEntry(key: key, value: value, type: type));
      }

      setState(() {
        _entries = entries;
        _filteredEntries = entries;
        _isLoading = false;
        _selectedEntry = null;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  SharedPreferencesType _getType(Object? value) {
    if (value is String) return SharedPreferencesType.string;
    if (value is int) return SharedPreferencesType.int;
    if (value is double) return SharedPreferencesType.double;
    if (value is bool) return SharedPreferencesType.bool;
    if (value is List<String>) return SharedPreferencesType.stringList;
    return SharedPreferencesType.string;
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEntries = _entries;
      } else {
        _filteredEntries = _entries
            .where((e) => e.key.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectEntry(SharedPreferencesEntry entry) {
    setState(() => _selectedEntry = entry);
  }

  Future<void> _deleteEntry(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await _loadData();
  }

  Future<void> _updateEntry(
      String key, Object newValue, SharedPreferencesType type) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case SharedPreferencesType.string:
        await prefs.setString(key, newValue as String);
      case SharedPreferencesType.int:
        await prefs.setInt(key, newValue as int);
      case SharedPreferencesType.double:
        await prefs.setDouble(key, newValue as double);
      case SharedPreferencesType.bool:
        await prefs.setBool(key, newValue as bool);
      case SharedPreferencesType.stringList:
        await prefs.setStringList(key, newValue as List<String>);
    }
    await _loadData();
  }

  void _setEditing(bool editing) {
    setState(() => _isEditing = editing);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      contentWidget: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Column(
              children: [
                if (!_isEditing) ...[
                  Expanded(
                    flex: 3,
                    child: _KeysListWidget(
                      entries: _filteredEntries,
                      selectedEntry: _selectedEntry,
                      onSelect: _selectEntry,
                      showSearch: _showSearch,
                      searchQuery: _searchQuery,
                      onFilter: _filter,
                    ),
                  ),
                  const Divider(height: 1),
                ],
                Expanded(
                  flex: _isEditing ? 1 : 2,
                  child: _DataPanelWidget(
                    key: ValueKey(_selectedEntry?.key),
                    entry: _selectedEntry,
                    onDelete: _deleteEntry,
                    onUpdate: _updateEntry,
                    onEditingChanged: _setEditing,
                  ),
                ),
              ],
            ),
      toolbarActions: [
        Tuple3(
          'Search',
          const Icon(Icons.search, size: 20),
          () => setState(() => _showSearch = !_showSearch),
        ),
        Tuple3(
          'Refresh',
          const Icon(Icons.refresh, size: 20),
          _loadData,
        ),
      ],
      closeAction: UMEWidget.closeActivatedPlugin,
    );
  }
}
