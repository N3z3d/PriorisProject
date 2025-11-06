part of 'state_management_mixin.dart';

class _LoadingStateController {
  _LoadingStateController(this._notify);

  final VoidCallback _notify;
  bool _isLoading = false;
  String? _message;
  final Set<String> _operationKeys = <String>{};

  bool get isLoading => _isLoading;
  String? get message => _message;

  bool isOperationLoading(String key) => _operationKeys.contains(key);

  void setLoading(bool value, String? message) {
    if (value) {
      final changed = !_isLoading || _message != message;
      _isLoading = true;
      _message = message;
      if (changed) {
        _notify();
      }
    } else {
      if (!_isLoading && _message == null) {
        return;
      }
      _isLoading = false;
      _message = null;
      _notify();
    }
  }

  void setOperationLoading(String key, bool value) {
    final changed =
        value ? _operationKeys.add(key) : _operationKeys.remove(key);
    if (changed) {
      _notify();
    }
  }

  void clear() {
    if (!_isLoading && _message == null && _operationKeys.isEmpty) return;
    _isLoading = false;
    _message = null;
    if (_operationKeys.isNotEmpty) {
      _operationKeys.clear();
    }
    _notify();
  }
}

class _ErrorStateController {
  _ErrorStateController(this._notify);

  final VoidCallback _notify;
  String? _lastError;
  final Map<String, String> _operationErrors = {};

  String? get lastError => _lastError;
  bool get hasErrors => _lastError != null || _operationErrors.isNotEmpty;

  String? getOperationError(String key) => _operationErrors[key];

  void setError(String? message) {
    if (_lastError == message) return;
    _lastError = message;
    _notify();
  }

  void setOperationError(String key, String? message) {
    if (message == null) {
      if (_operationErrors.remove(key) != null) {
        _notify();
      }
    } else {
      final previous = _operationErrors[key];
      if (previous == message) return;
      _operationErrors[key] = message;
      _notify();
    }
  }

  void clearAll() {
    if (!hasErrors) return;
    _lastError = null;
    _operationErrors.clear();
    _notify();
  }
}

class _DataStateController<T> {
  _DataStateController(this._notify);

  final VoidCallback _notify;
  T? _data;
  bool _isInitialized = false;
  bool _isEmpty = false;

  T? get data => _data;
  bool get isInitialized => _isInitialized;
  bool get isEmpty => _isEmpty;
  bool get hasData => _isInitialized && !_isEmpty;

  void setData(T? value) {
    final newEmpty = _computeEmpty(value);
    final changed = !_isInitialized || _data != value || _isEmpty != newEmpty;
    _data = value;
    _isInitialized = true;
    _isEmpty = newEmpty;
    if (changed) {
      _notify();
    }
  }

  void updateData(T? Function(T? current) updater) {
    setData(updater(_data));
  }

  void clear() {
    if (_data == null && !_isInitialized && !_isEmpty) return;
    _data = null;
    _isInitialized = false;
    _isEmpty = false;
    _notify();
  }

  bool _computeEmpty(T? value) {
    if (value == null) return true;
    if (value is Iterable) return value.isEmpty;
    if (value is String) return value.isEmpty;
    return false;
  }
}
