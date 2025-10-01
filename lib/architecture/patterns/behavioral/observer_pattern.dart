/// Observer Pattern Implementation
///
/// Behavioral pattern that defines a subscription mechanism to notify
/// multiple objects about events happening to the object they're observing.

abstract class Observer<T> {
  void onNotify(T data);
}

abstract class Subject<T> {
  final List<Observer<T>> _observers = [];

  void addObserver(Observer<T> observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  void removeObserver(Observer<T> observer) {
    _observers.remove(observer);
  }

  void notifyObservers(T data) {
    for (final observer in List.from(_observers)) {
      try {
        observer.onNotify(data);
      } catch (e) {
        // Log error but continue notifying other observers
        print('Error notifying observer: $e');
      }
    }
  }

  void clearObservers() {
    _observers.clear();
  }

  int get observerCount => _observers.length;
}

/// Event-based observer for typed events
class EventObserver<T> extends Subject<T> {
  void publish(T event) {
    notifyObservers(event);
  }
}

/// Observable value that notifies on changes
class ObservableValue<T> extends Subject<T> {
  T _value;

  ObservableValue(this._value);

  T get value => _value;

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyObservers(_value);
    }
  }
}

/// Multi-event observer for different event types
class MultiEventObserver {
  final Map<Type, Subject> _subjects = {};

  Subject<T> getSubject<T>() {
    return _subjects.putIfAbsent(T, () => EventObserver<T>()) as Subject<T>;
  }

  void addObserver<T>(Observer<T> observer) {
    getSubject<T>().addObserver(observer);
  }

  void removeObserver<T>(Observer<T> observer) {
    getSubject<T>().removeObserver(observer);
  }

  void publish<T>(T event) {
    (getSubject<T>() as EventObserver<T>).publish(event);
  }

  void clearAll() {
    for (final subject in _subjects.values) {
      subject.clearObservers();
    }
    _subjects.clear();
  }
}