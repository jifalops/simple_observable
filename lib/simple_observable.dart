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
    // When multiple synchronous changes to [value] happen, only the first
    // change is emitted from [nextValue] and [values], unless [_notify()] is
    // delayed by some duration. [Future.microtask()] does not solve the issue.
    Future.delayed(Duration(microseconds: 1), () => _notify(val));
  }

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
