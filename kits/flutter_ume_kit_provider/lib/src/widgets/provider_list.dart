part of '../../flutter_ume_kit_provider_plus.dart';

class _ProviderListWidget extends StatelessWidget {
  final List<ProviderNode> providers;
  final ProviderNode? selectedProvider;
  final ValueChanged<ProviderNode> onSelect;
  final bool showSearch;
  final String searchQuery;
  final ValueChanged<String> onFilter;

  const _ProviderListWidget({
    required this.providers,
    required this.selectedProvider,
    required this.onSelect,
    required this.showSearch,
    required this.searchQuery,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showSearch)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search providers...',
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: onFilter,
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Text(
                'Providers (${providers.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: providers.isEmpty
              ? Center(
                  child: Text(
                    searchQuery.isEmpty
                        ? 'No providers found'
                        : 'No matching providers',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    final isSelected = provider.id == selectedProvider?.id;

                    return _ProviderListTile(
                      provider: provider,
                      isSelected: isSelected,
                      onTap: () => onSelect(provider),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ProviderListTile extends StatelessWidget {
  final ProviderNode provider;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProviderListTile({
    required this.provider,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.type,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.blue.shade700 : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _getValuePreview(provider.value),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getValuePreview(Object? value) {
    if (value == null) return 'null';
    if (value is String) {
      if (value.length > 30) return '"${value.substring(0, 30)}..."';
      return '"$value"';
    }
    if (value is num || value is bool) return value.toString();
    if (value is List) return 'List(${value.length})';
    if (value is Map) return 'Map(${value.length})';
    if (value is Set) return 'Set(${value.length})';
    return value.runtimeType.toString();
  }
}
