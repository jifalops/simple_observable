# simple_observable

A minimal observable and debouncer that works with callbacks, Futures, Streams, or any combination of the three.

## Usage

```dart
import 'package:simple_observable/simple_observable.dart';

void main() {
  // Without a callback
  final observable = SimpleObservable<String>();
  // With a callback
  final observable2 = SimpleObservable<String>(print);

  // Using a Future
  observable.nextValue.then((value) => print('Future: $value'));

  // Using a Stream
  observable.values.listen((value) => print('Stream: $value'));

  // Changing its value
  observable.value = 'foo';
  observable.value = 'bar';


  // Debouncing
  final debouncer = Debouncer<String>(Duration(milliseconds: 250));

  // Everything works the same as above.

  // Using a Future
  debouncer.nextValue.then((value) => print('Future: $value'));

  // Using a Stream
  debouncer.values.listen((value) => print('Stream: $value'));

  // Changing its value
  debouncer.value = 'foo';
  debouncer.value = 'bar';
}
```

## Source code

```dart
import 'dart:async';

/// A simple class that allows being notified of changes [value] via the
/// [onValue] callback, the [nextValue] Future, or the [values] Stream.
///
/// Any combination of [onValue], [nextValue], and [values] can be used to
/// listen for changes.
class SimpleObservable<T> {
  SimpleObservable([this.onValue]);
  final Function(T value) onValue;
  var _completer = Completer<T>();
  T _value;
  T get value => _value;
  set value(T val) {
    _value = val;
    // Delaying notify() fixes issues with the Future and Stream no updating.
    Future.delayed(Duration(microseconds: 1), () => _notify(val));
  }

  /// Alias for [value] setter. Good for passing to a Future or Stream.
  void setValue(T val) => value = val;

  void _notify(T val) {
    if (onValue != null) onValue(val);
    // Completing with a microtask allows a new Completer to be constructed
    // before listeners of [nextValue] are called, allowing them to listen to
    // nextValue again if desired.
    _completer.complete(Future.microtask(() => val));
    _completer = Completer<T>();
  }

  Future<T> get nextValue => _completer.future;
  Stream<T> get values async* {
    while (true) yield await nextValue;
  }
}

/// Debounces value changes by updating [onValue], [nextValue], and [values]
/// only after [duration] has elapsed without additional changes.
class Debouncer<T> extends SimpleObservable<T> {
  Debouncer(this.duration, [Function(T value) onValue]) : super(onValue);
  final Duration duration;
  Timer _timer;
  bool _canceled = false;
  bool get canceled => _canceled;
  var _completer = Completer<T>();
  set value(T val) {
    if (!canceled) {
      _value = val;
      _timer?.cancel();
      _timer = Timer(duration, () {
        if (!canceled) {
          _notify(value);
        }
      });
    }
  }

  /// Disables the callback and changes to [value].
  void cancel() {
    _timer?.cancel();
    _canceled = true;
  }

  /// Undoes [cancel()] by reenabling the callback and allowing changes to
  /// [value].
  void restart() => _canceled = false;
}
```