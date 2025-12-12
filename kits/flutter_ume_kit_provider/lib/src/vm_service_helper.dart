part of '../flutter_ume_kit_provider_plus.dart';

/// Simplified EvalOnDartLibrary for flutter_ume
/// Based on devtools_app_shared implementation
class EvalOnDartLibrary {
  EvalOnDartLibrary(
    this.libraryName,
    this.service,
    this.isolateId,
  );

  final String libraryName;
  final vm.VmService service;
  final String isolateId;

  String? _libraryId;
  bool _disposed = false;

  /// Initialize and find the library
  Future<bool> initialize() async {
    if (_libraryId != null) return true;

    try {
      final isolate = await service.getIsolate(isolateId);
      final libraries = isolate.libraries ?? [];

      for (final library in libraries) {
        if (library.uri == libraryName) {
          _libraryId = library.id;
          return true;
        }
      }

      debugPrint('EvalOnDartLibrary: Library $libraryName not found');
      return false;
    } catch (e) {
      debugPrint('EvalOnDartLibrary: Failed to initialize: $e');
      return false;
    }
  }

  /// Evaluate an expression and return InstanceRef
  Future<vm.InstanceRef?> eval(
    String expression, {
    Map<String, String>? scope,
  }) async {
    if (_disposed) return null;

    if (_libraryId == null) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    try {
      final result = await service.evaluate(
        isolateId,
        _libraryId!,
        expression,
        scope: scope,
        disableBreakpoints: true,
      );

      if (result is vm.Sentinel) {
        return null;
      }
      if (result is vm.ErrorRef) {
        debugPrint('EvalOnDartLibrary: Eval error: ${result.message}');
        return null;
      }
      return result as vm.InstanceRef;
    } catch (e) {
      debugPrint('EvalOnDartLibrary: Eval failed for "$expression": $e');
      return null;
    }
  }

  /// Evaluate and get full Instance
  Future<vm.Instance?> evalInstance(
    String expression, {
    Map<String, String>? scope,
  }) async {
    final ref = await eval(expression, scope: scope);
    if (ref == null) return null;
    return getInstance(ref);
  }

  /// Get full Instance from InstanceRef
  Future<vm.Instance?> getInstance(vm.InstanceRef ref) async {
    if (_disposed) return null;

    try {
      final obj = await service.getObject(isolateId, ref.id!);
      if (obj is vm.Instance) {
        return obj;
      }
      return null;
    } catch (e) {
      debugPrint('EvalOnDartLibrary: getInstance failed: $e');
      return null;
    }
  }

  /// Get Class from ClassRef
  Future<vm.Class?> getClass(vm.ClassRef ref) async {
    if (_disposed) return null;

    try {
      final obj = await service.getObject(isolateId, ref.id!);
      if (obj is vm.Class) {
        return obj;
      }
      return null;
    } catch (e) {
      debugPrint('EvalOnDartLibrary: getClass failed: $e');
      return null;
    }
  }

  void dispose() {
    _disposed = true;
  }
}

/// Helper class to interact with VM Service for object inspection
/// Uses VMServiceWrapper mixin from flutter_ume_plus (same as flutter_ume_kit_perf)
class VmServiceHelper with VMServiceWrapper {
  static VmServiceHelper? _instance;
  static VmServiceHelper get instance => _instance ??= VmServiceHelper._();

  VmServiceHelper._();

  vm.VmService? _service;
  String? _isolateId;
  bool _isConnected = false;

  EvalOnDartLibrary? _providerEval;
  EvalOnDartLibrary? _defaultEval;
  final _libraryEvalCache = <String, EvalOnDartLibrary>{};

  /// Check if VM Service is available
  bool get isAvailable =>
      _isConnected && _service != null && _isolateId != null;

  vm.VmService? get service => _service;
  String? get isolateId => _isolateId;

  /// Connect to VM Service using flutter_ume_plus's ServiceWrapper
  Future<bool> connect() async {
    if (_isConnected && _service != null) return true;

    try {
      // Use the serviceWrapper from VMServiceWrapper mixin (same as flutter_ume_kit_perf)
      _service = await serviceWrapper.getVMService();
      _isolateId = serviceWrapper.isolateId;
      _isConnected = true;

      debugPrint(
          'VmServiceHelper: Connected to VM Service, isolateId: $_isolateId');
      return true;
    } catch (e) {
      debugPrint('VmServiceHelper: Failed to connect: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Get EvalOnDartLibrary for provider package
  Future<EvalOnDartLibrary?> getProviderEval() async {
    if (!isAvailable) {
      await connect();
      if (!isAvailable) return null;
    }

    _providerEval ??= EvalOnDartLibrary(
      'package:provider/src/provider.dart',
      _service!,
      _isolateId!,
    );

    if (await _providerEval!.initialize()) {
      return _providerEval;
    }
    return null;
  }

  /// Get EvalOnDartLibrary for a specific library
  Future<EvalOnDartLibrary?> getLibraryEval(String libraryUri) async {
    if (!isAvailable) {
      await connect();
      if (!isAvailable) return null;
    }

    var eval = _libraryEvalCache[libraryUri];
    if (eval != null) return eval;

    eval = EvalOnDartLibrary(libraryUri, _service!, _isolateId!);
    if (await eval.initialize()) {
      _libraryEvalCache[libraryUri] = eval;
      return eval;
    }
    return null;
  }

  /// Get default eval (dart:core)
  Future<EvalOnDartLibrary?> getDefaultEval() async {
    if (!isAvailable) {
      await connect();
      if (!isAvailable) return null;
    }

    _defaultEval ??= EvalOnDartLibrary('dart:core', _service!, _isolateId!);

    if (await _defaultEval!.initialize()) {
      return _defaultEval;
    }
    return null;
  }

  /// Get all provider IDs using eval
  Future<List<String>> getProviderIds() async {
    final eval = await getProviderEval();
    if (eval == null) return [];

    try {
      final instance = await eval.evalInstance(
        'ProviderBinding.debugInstance.providerDetails.keys.toList()',
      );

      if (instance == null || instance.elements == null) return [];

      final ids = <String>[];
      for (final element in instance.elements!) {
        if (element is vm.InstanceRef) {
          final idInstance = await eval.getInstance(element);
          if (idInstance?.valueAsString != null) {
            ids.add(idInstance!.valueAsString!);
          }
        }
      }
      return ids;
    } catch (e) {
      debugPrint('VmServiceHelper: Failed to get provider IDs: $e');
      return [];
    }
  }

  /// Get provider node info using eval
  Future<ProviderNode?> getProviderNode(String providerId) async {
    final eval = await getProviderEval();
    if (eval == null) return null;

    try {
      final instance = await eval.evalInstance(
        "ProviderBinding.debugInstance.providerDetails['$providerId']",
      );

      if (instance == null || instance.fields == null) return null;

      // Get type field
      String? type;
      for (final field in instance.fields!) {
        if (field.decl?.name == 'type') {
          final typeRef = field.value;
          if (typeRef is vm.InstanceRef) {
            final typeInstance = await eval.getInstance(typeRef);
            type = typeInstance?.valueAsString;
          }
          break;
        }
      }

      return ProviderNode(
        id: providerId,
        type: type ?? 'Unknown',
        value: null, // Value will be loaded separately
      );
    } catch (e) {
      debugPrint('VmServiceHelper: Failed to get provider node: $e');
      return null;
    }
  }

  /// Get provider value InstanceRef using eval
  Future<vm.InstanceRef?> getProviderValueRef(String providerId) async {
    final eval = await getProviderEval();
    if (eval == null) return null;

    return eval.eval(
      "ProviderBinding.debugInstance.providerDetails['$providerId']?.value",
    );
  }

  /// Get instance details (fields) from InstanceRef
  Future<InstanceDetails?> getInstanceDetails(vm.InstanceRef ref) async {
    final eval = await getDefaultEval();
    if (eval == null) return null;

    try {
      final instance = await eval.getInstance(ref);
      if (instance == null) return null;

      return _parseInstance(instance, ref.id!);
    } catch (e) {
      debugPrint('VmServiceHelper: Failed to get instance details: $e');
      return null;
    }
  }

  /// Parse Instance to InstanceDetails
  Future<InstanceDetails?> _parseInstance(
      vm.Instance instance, String refId) async {
    switch (instance.kind) {
      case vm.InstanceKind.kNull:
        return InstanceDetails.nil();

      case vm.InstanceKind.kBool:
        return InstanceDetails.boolean(
          instance.valueAsString ?? 'false',
          instanceRefId: refId,
        );

      case vm.InstanceKind.kInt:
      case vm.InstanceKind.kDouble:
        return InstanceDetails.number(
          instance.valueAsString ?? '0',
          instanceRefId: refId,
        );

      case vm.InstanceKind.kString:
        return InstanceDetails.string(
          instance.valueAsString ?? '',
          instanceRefId: refId,
        );

      case vm.InstanceKind.kList:
        return InstanceDetails.list(
          length: instance.length ?? 0,
          instanceRefId: refId,
          elements: instance.elements,
        );

      case vm.InstanceKind.kMap:
        return InstanceDetails.map(
          length: instance.length ?? 0,
          instanceRefId: refId,
          associations: instance.associations,
        );

      case vm.InstanceKind.kPlainInstance:
      default:
        // Check if it's an enum
        final enumDetails = await _tryParseEnum(instance, refId);
        if (enumDetails != null) return enumDetails;

        // Parse as object
        final fields = await _parseObjectFields(instance);
        return InstanceDetails.object(
          type: instance.classRef?.name ?? 'Object',
          instanceRefId: refId,
          fields: fields,
        );
    }
  }

  /// Try to parse as enum
  Future<InstanceDetails?> _tryParseEnum(
      vm.Instance instance, String refId) async {
    if (instance.kind != vm.InstanceKind.kPlainInstance ||
        instance.fields?.length != 2) {
      return null;
    }

    vm.InstanceRef? findField(String name) {
      return instance.fields
          ?.firstWhereOrNull((f) => f.decl?.name == name)
          ?.value as vm.InstanceRef?;
    }

    final nameRef = findField('_name');
    final indexRef = findField('index');
    if (nameRef == null || indexRef == null) return null;

    final eval = await getDefaultEval();
    if (eval == null) return null;

    final nameInstance = await eval.getInstance(nameRef);
    final indexInstance = await eval.getInstance(indexRef);

    if (nameInstance?.kind != vm.InstanceKind.kString ||
        indexInstance?.kind != vm.InstanceKind.kInt) {
      return null;
    }

    final nameSplit = (nameInstance!.valueAsString ?? '').split('.');
    return InstanceDetails.enumeration(
      type: instance.classRef?.name ?? 'Enum',
      value: nameSplit.last,
      instanceRefId: refId,
    );
  }

  /// Parse object fields
  Future<List<ObjectField>> _parseObjectFields(vm.Instance instance) async {
    final fields = <ObjectField>[];
    final boundFields = instance.fields;

    if (boundFields == null || boundFields.isEmpty) {
      return fields;
    }

    final eval = await getDefaultEval();

    for (final field in boundFields) {
      final decl = field.decl;
      if (decl == null) continue;

      final name = decl.name ?? 'unknown';
      final isFinal = decl.isFinal ?? false;
      final value = field.value;

      String? ownerName;
      String? ownerUri;

      // Get owner info
      if (decl.owner != null && eval != null) {
        try {
          final ownerClass = await eval.getClass(decl.owner! as vm.ClassRef);
          if (ownerClass != null) {
            ownerName = ownerClass.mixin?.name ?? ownerClass.name;
            ownerUri = decl.location?.script?.uri;
          }
        } catch (_) {}
      }

      fields.add(ObjectField(
        name: name,
        isFinal: isFinal,
        isPrivate: name.startsWith('_'),
        ownerName: ownerName,
        ownerUri: ownerUri,
        ref: value is vm.InstanceRef ? value : null,
        value: value,
      ));
    }

    // Sort fields by name
    fields.sort((a, b) => _sortFieldsByName(a.name, b.name));
    return fields;
  }

  int _sortFieldsByName(String a, String b) {
    final aIsPrivate = a.startsWith('_');
    final bIsPrivate = b.startsWith('_');
    if (aIsPrivate != bIsPrivate) {
      return aIsPrivate ? 1 : -1;
    }
    return a.compareTo(b);
  }

  /// Dispose
  void dispose() {
    _providerEval?.dispose();
    _defaultEval?.dispose();
    for (final eval in _libraryEvalCache.values) {
      eval.dispose();
    }
    _libraryEvalCache.clear();
    // Don't dispose _service - it's managed by serviceWrapper
    _service = null;
    _isolateId = null;
    _isConnected = false;
    _instance = null;
  }
}

/// Object field info
class ObjectField {
  final String name;
  final bool isFinal;
  final bool isPrivate;
  final String? ownerName;
  final String? ownerUri;
  final vm.InstanceRef? ref;
  final dynamic value;

  ObjectField({
    required this.name,
    this.isFinal = false,
    this.isPrivate = false,
    this.ownerName,
    this.ownerUri,
    this.ref,
    this.value,
  });

  String get typeName {
    if (ref != null) {
      return ref!.classRef?.name ?? ref!.kind ?? 'Object';
    }
    return value?.runtimeType.toString() ?? 'Null';
  }
}

/// Instance details - similar to provider-dev's InstanceDetails
sealed class InstanceDetails {
  const InstanceDetails();

  factory InstanceDetails.nil() = NullInstance;

  factory InstanceDetails.boolean(String displayString,
      {required String instanceRefId}) = BoolInstance;

  factory InstanceDetails.number(String displayString,
      {required String instanceRefId}) = NumInstance;

  factory InstanceDetails.string(String displayString,
      {required String instanceRefId}) = StringInstance;

  factory InstanceDetails.list({
    required int length,
    required String instanceRefId,
    List<dynamic>? elements,
  }) = ListInstance;

  factory InstanceDetails.map({
    required int length,
    required String instanceRefId,
    List<vm.MapAssociation>? associations,
  }) = MapInstance;

  factory InstanceDetails.object({
    required String type,
    required String instanceRefId,
    required List<ObjectField> fields,
  }) = ObjectInstance;

  factory InstanceDetails.enumeration({
    required String type,
    required String value,
    required String instanceRefId,
  }) = EnumInstance;

  bool get isExpandable;
  String? get instanceRefId;
}

class NullInstance extends InstanceDetails {
  const NullInstance();

  @override
  bool get isExpandable => false;

  @override
  String? get instanceRefId => null;
}

class BoolInstance extends InstanceDetails {
  final String displayString;
  @override
  final String instanceRefId;

  const BoolInstance(this.displayString, {required this.instanceRefId});

  @override
  bool get isExpandable => false;
}

class NumInstance extends InstanceDetails {
  final String displayString;
  @override
  final String instanceRefId;

  const NumInstance(this.displayString, {required this.instanceRefId});

  @override
  bool get isExpandable => false;
}

class StringInstance extends InstanceDetails {
  final String displayString;
  @override
  final String instanceRefId;

  const StringInstance(this.displayString, {required this.instanceRefId});

  @override
  bool get isExpandable => false;
}

class ListInstance extends InstanceDetails {
  final int length;
  @override
  final String instanceRefId;
  final List<dynamic>? elements;

  const ListInstance({
    required this.length,
    required this.instanceRefId,
    this.elements,
  });

  @override
  bool get isExpandable => length > 0;
}

class MapInstance extends InstanceDetails {
  final int length;
  @override
  final String instanceRefId;
  final List<vm.MapAssociation>? associations;

  const MapInstance({
    required this.length,
    required this.instanceRefId,
    this.associations,
  });

  @override
  bool get isExpandable => length > 0;
}

class ObjectInstance extends InstanceDetails {
  final String type;
  @override
  final String instanceRefId;
  final List<ObjectField> fields;

  const ObjectInstance({
    required this.type,
    required this.instanceRefId,
    required this.fields,
  });

  @override
  bool get isExpandable => fields.isNotEmpty;
}

class EnumInstance extends InstanceDetails {
  final String type;
  final String value;
  @override
  final String instanceRefId;

  const EnumInstance({
    required this.type,
    required this.value,
    required this.instanceRefId,
  });

  @override
  bool get isExpandable => false;
}
