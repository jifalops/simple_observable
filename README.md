![pub.dev](https://img.shields.io/badge/pub-v1.0.0-blue)

# simple_observable

Observe value changes using a `Future`, `Stream`, and/or a callback.

## Source

```dart
class Observable<T> {
  Observable({T initialValue, this.onChanged, this.checkEquality = true})
      : _value = initialValue;

  /// If true, setting the [value] will only notifiy if the new value is different
  /// than the current value.
  final bool checkEquality;
  final void Function(T value) onChanged;

  var _completer = Completer<T>();

  bool _canceled = false;
  bool get canceled => _canceled;

  T _value;

  /// The current value of this observable.
  T get value => _value;
  set value(T val) {
    if (!canceled && (!checkEquality || _value != val)) {
      _value = val;
      // Delaying notify() allows the Future and Stream to update correctly.
      Future.delayed(Duration(microseconds: 1), () => notify(val));
    }
  }

  /// Alias for [value] setter. Good for passing to a Future or Stream.
  void setValue(T val) => value = val;

  @protected
  @mustCallSuper
  void notify(T val) {
    if (onChanged != null) onChanged(val);
    // Completing with a microtask allows a new completer to be constructed
    // before listeners of [nextValue] are called, allowing them to listen to
    // nextValue again if desired.
    _completer.complete(Future.microtask(() => val));
    _completer = Completer<T>();
  }

  Future<T> get nextValue => _completer.future;
  Stream<T> get values async* {
    while (!canceled) {
      yield await nextValue;
    }
  }

  /// Permanently disables this observable. Further changes to [value] will be
  /// ignored, the outputs [onChanged], [nextValue], and [values] will not be
  /// called again.
  @mustCallSuper
  void cancel() => _canceled = true;
}
```
