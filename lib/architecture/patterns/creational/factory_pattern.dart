/// Factory Pattern Implementation
///
/// Creational pattern that creates objects without specifying
/// the exact class of object that will be created.

/// Abstract factory interface
abstract class Factory<T> {
  T create();
  String get type;
}

/// Generic factory implementation
class GenericFactory<T> implements Factory<T> {
  final T Function() _creator;
  final String _type;

  GenericFactory(this._creator, this._type);

  @override
  T create() => _creator();

  @override
  String get type => _type;
}

/// Parametrized factory for complex object creation
class ParametrizedFactory<T, TParams> {
  final T Function(TParams) _creator;
  final String _type;

  ParametrizedFactory(this._creator, this._type);

  T create(TParams params) => _creator(params);

  String get type => _type;
}

/// Factory registry for managing multiple factories
class FactoryRegistry<T> {
  final Map<String, Factory<T>> _factories = {};
  String? _defaultFactory;

  void register(String key, Factory<T> factory) {
    _factories[key] = factory;
  }

  void setDefault(String key) {
    if (_factories.containsKey(key)) {
      _defaultFactory = key;
    }
  }

  T? create(String key) {
    final factory = _factories[key];
    return factory?.create();
  }

  T? createDefault() {
    if (_defaultFactory != null) {
      return create(_defaultFactory!);
    }
    return null;
  }

  List<String> get availableTypes => _factories.keys.toList();

  Map<String, String> get factoryTypes => _factories.map(
        (key, factory) => MapEntry(key, factory.type),
      );
}

/// Abstract factory for creating families of related objects
abstract class AbstractFactory {
  String get familyName;
  List<String> get supportedTypes;
}

/// Concrete abstract factory implementation
class ConcreteAbstractFactory extends AbstractFactory {
  final String _familyName;
  final Map<String, dynamic Function()> _creators = {};

  ConcreteAbstractFactory(this._familyName);

  void registerCreator<T>(String type, T Function() creator) {
    _creators[type] = creator;
  }

  T? create<T>(String type) {
    final creator = _creators[type];
    return creator?.call() as T?;
  }

  @override
  String get familyName => _familyName;

  @override
  List<String> get supportedTypes => _creators.keys.toList();
}

/// Factory method pattern implementation
abstract class Creator<T> {
  T factoryMethod();

  // Template method that uses the factory method
  T createObject() {
    final obj = factoryMethod();
    // Additional setup can be done here
    return obj;
  }
}

/// Lazy factory for deferred object creation
class LazyFactory<T> implements Factory<T> {
  final T Function() _creator;
  final String _type;
  T? _instance;

  LazyFactory(this._creator, this._type);

  @override
  T create() {
    _instance ??= _creator();
    return _instance!;
  }

  @override
  String get type => _type;

  void reset() {
    _instance = null;
  }

  bool get isCreated => _instance != null;
}