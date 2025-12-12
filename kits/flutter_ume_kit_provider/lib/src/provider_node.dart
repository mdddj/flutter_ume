part of '../flutter_ume_kit_provider_plus.dart';

/// Represents a Provider node
@immutable
class ProviderNode {
  const ProviderNode({
    required this.id,
    required this.type,
    this.value,
    this.valueRef,
  });

  final String id;
  final String type;
  final Object? value;
  final vm.InstanceRef? valueRef;
}

/// Scans providers using VM Service eval
class ProviderScanner {
  /// Get all providers using VM Service eval
  static Future<List<ProviderNode>> scanViaEval() async {
    final helper = VmServiceHelper.instance;

    // Get all provider IDs
    final ids = await helper.getProviderIds();
    if (ids.isEmpty) {
      debugPrint('ProviderScanner: No provider IDs found via eval');
      return [];
    }

    debugPrint('ProviderScanner: Found ${ids.length} providers via eval');

    // Get provider nodes
    final nodes = <ProviderNode>[];
    for (final id in ids) {
      final node = await helper.getProviderNode(id);
      if (node != null) {
        // Get value ref
        final valueRef = await helper.getProviderValueRef(id);
        nodes.add(ProviderNode(
          id: node.id,
          type: node.type,
          valueRef: valueRef,
        ));
      }
    }

    return nodes..sort((a, b) => a.type.compareTo(b.type));
  }

  /// Fallback: Get providers from ProviderBinding directly (for when VM Service is not available)
  static List<ProviderNode> scanFromBinding() {
    final providers = <ProviderNode>[];

    try {
      final binding = ProviderBinding.debugInstance;
      final details = binding.providerDetails;

      for (final entry in details.entries) {
        providers.add(ProviderNode(
          id: entry.key,
          type: entry.value.type,
          value: entry.value.value,
        ));
      }
    } catch (e) {
      debugPrint('ProviderScanner.scanFromBinding error: $e');
    }

    return providers..sort((a, b) => a.type.compareTo(b.type));
  }
}
