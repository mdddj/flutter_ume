part of '../../flutter_ume_kit_shared_preferences_plus.dart';

class _KeysListWidget extends StatelessWidget {
  final List<SharedPreferencesEntry> entries;
  final SharedPreferencesEntry? selectedEntry;
  final ValueChanged<SharedPreferencesEntry> onSelect;
  final bool showSearch;
  final String searchQuery;
  final ValueChanged<String> onFilter;

  const _KeysListWidget({
    required this.entries,
    required this.selectedEntry,
    required this.onSelect,
    required this.showSearch,
    required this.searchQuery,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Text(
                'Keys (${entries.length})',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
        if (showSearch)
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search keys...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: onFilter,
            ),
          ),
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Text(
                    searchQuery.isEmpty ? 'No data' : 'No results',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: entries.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isSelected = selectedEntry?.key == entry.key;
                    return InkWell(
                      onTap: () => onSelect(entry),
                      child: Container(
                        color: isSelected ? Colors.blue.shade50 : null,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                entry.typeLabel,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
