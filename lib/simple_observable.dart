import 'dart:async';
import 'package:meta/meta.dart';

/// A simple class that allows being notified of changes [value] via the
/// [onValue] callback, the [nextValue] Future, or the [values] Stream.
///
/// Any combination of [onValue], [nextValue], and [values] can be used to
/// listen for changes.
///
/// Once canceled, it cannot be reused. Instead, create another instance.
class SimpleObservable<T> {
  SimpleObservable([this.onValue]);

  final void Function(T value) onValue;

  var _completer = Completer<T>();

  bool _canceled = false;
  bool get canceled => _canceled;

  T _value;

  /// The current value of this observable.
  T get value => _value;
  set value(T val) {
    if (!canceled) {
      _value = val;
      // Delaying notify() allows the Future and Stream to update correctly.
      Future.delayed(Duration(microseconds: 1), () => _notify(val));
    }
  }

  /// Alias for [value] setter. Good for passing to a Future or Stream.
  void setValue(T val) => value = val;

  void _notify(T val) {
    if (onValue != null) onValue(val);
    // Completing with a microtask allows a new completer to be constructed
    // before listeners of [nextValue] are called, allowing them to listen to
    // nextValue again if desired.
    _completer.complete(Future.microtask(() => val));
    _completer = Completer<T>();
  }

  Future<T> get nextValue => _completer.future;
  Stream<T> get values async* {
    while (!canceled) yield await nextValue;
  }

  /// Permanently disables this observable. Further changes to [value] will be
  /// ignored, the outputs [onValue], [nextValue], and [values] will not be
  /// called again.
  @mustCallSuper
  void cancel() => _canceled = true;
}

/// Debounces value changes by updating [onValue], [nextValue], and [values]
/// only after [duration] has elapsed without additional changes.
class Debouncer<T> extends SimpleObservable<T> {
  Debouncer(this.duration, [void Function(T value) onValue]) : super(onValue);
  final Duration duration;
  Timer _timer;

  /// The most recent value, without waiting for the debounce timer to expire.
  @override
  T get value => super.value;

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

  @override
  @mustCallSuper
  void cancel() {
    super.cancel();
    _timer?.cancel();
  }
}
