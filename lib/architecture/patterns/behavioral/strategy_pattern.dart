/// Strategy Pattern Implementation
///
/// Behavioral pattern that defines a family of algorithms,
/// encapsulates each one, and makes them interchangeable.

abstract class Strategy<TInput, TOutput> {
  TOutput execute(TInput input);
  String get name;
  String get description;
}

/// Context that uses strategies
class StrategyContext<TInput, TOutput> {
  Strategy<TInput, TOutput>? _strategy;

  StrategyContext([this._strategy]);

  void setStrategy(Strategy<TInput, TOutput> strategy) {
    _strategy = strategy;
  }

  TOutput? execute(TInput input) {
    return _strategy?.execute(input);
  }

  String? get currentStrategyName => _strategy?.name;
}

/// Strategy registry for managing multiple strategies
class StrategyRegistry<TInput, TOutput> {
  final Map<String, Strategy<TInput, TOutput>> _strategies = {};
  Strategy<TInput, TOutput>? _defaultStrategy;

  void register(String key, Strategy<TInput, TOutput> strategy) {
    _strategies[key] = strategy;
  }

  void setDefault(String key) {
    final strategy = _strategies[key];
    if (strategy != null) {
      _defaultStrategy = strategy;
    }
  }

  Strategy<TInput, TOutput>? get(String key) {
    return _strategies[key];
  }

  TOutput? execute(String key, TInput input) {
    final strategy = _strategies[key];
    return strategy?.execute(input);
  }

  TOutput? executeDefault(TInput input) {
    return _defaultStrategy?.execute(input);
  }

  List<String> get availableStrategies => _strategies.keys.toList();

  Map<String, String> get strategyDescriptions => _strategies.map(
        (key, strategy) => MapEntry(key, strategy.description),
      );
}

/// Composite strategy that combines multiple strategies
class CompositeStrategy<TInput, TOutput> extends Strategy<TInput, TOutput> {
  final List<Strategy<TInput, TOutput>> _strategies;
  final TOutput Function(List<TOutput>) _combiner;
  final String _name;
  final String _description;

  CompositeStrategy(
    this._strategies,
    this._combiner,
    this._name,
    this._description,
  );

  @override
  TOutput execute(TInput input) {
    final results = _strategies.map((strategy) => strategy.execute(input)).toList();
    return _combiner(results);
  }

  @override
  String get name => _name;

  @override
  String get description => _description;
}