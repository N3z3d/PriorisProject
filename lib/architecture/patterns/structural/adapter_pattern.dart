/// Adapter Pattern Implementation
///
/// Structural pattern that allows incompatible interfaces to work together
/// by wrapping an existing class with a new interface.

/// Target interface that clients expect
abstract class Target<T> {
  T request();
}

/// Existing class with incompatible interface
abstract class Adaptee<T> {
  T specificRequest();
}

/// Adapter that makes Adaptee compatible with Target
class Adapter<T> implements Target<T> {
  final Adaptee<T> _adaptee;

  Adapter(this._adaptee);

  @override
  T request() {
    // Convert the interface
    return _adaptee.specificRequest();
  }
}

/// Two-way adapter for bidirectional compatibility
class TwoWayAdapter<TTarget, TAdaptee> implements Target<TTarget> {
  final Adaptee<TAdaptee> _adaptee;
  final TTarget Function(TAdaptee) _forwardConverter;
  final TAdaptee Function(TTarget) _backwardConverter;

  TwoWayAdapter(
    this._adaptee,
    this._forwardConverter,
    this._backwardConverter,
  );

  @override
  TTarget request() {
    final result = _adaptee.specificRequest();
    return _forwardConverter(result);
  }

  TAdaptee reverseRequest(TTarget input) {
    return _backwardConverter(input);
  }
}

/// Generic function adapter
class FunctionAdapter<TInput, TOutput> {
  final TOutput Function(TInput) _function;

  FunctionAdapter(this._function);

  TOutput adapt(TInput input) => _function(input);
}

/// Multi-type adapter registry
class AdapterRegistry {
  final Map<String, dynamic> _adapters = {};

  void register<TTarget, TAdaptee>(
    String key,
    TwoWayAdapter<TTarget, TAdaptee> adapter,
  ) {
    _adapters[key] = adapter;
  }

  TwoWayAdapter<TTarget, TAdaptee>? get<TTarget, TAdaptee>(String key) {
    return _adapters[key] as TwoWayAdapter<TTarget, TAdaptee>?;
  }

  TTarget? adapt<TTarget, TAdaptee>(String key, TAdaptee input) {
    final adapter = get<TTarget, TAdaptee>(key);
    if (adapter != null) {
      return adapter._forwardConverter(input);
    }
    return null;
  }

  List<String> get registeredKeys => _adapters.keys.toList();
}