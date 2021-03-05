import 'dart:async';
import 'package:meta/meta.dart';

/// Observe value changes using a `Future`, `Stream`, and/or a callback.
class Observable<T> {
  Observable({required T initialValue, this.onChanged, this.checkEquality = true}) : _value = initialValue;

  /// If true, setting the [value] will only notifiy if the new value is different
  /// than the current value.
  final bool checkEquality;
  final void Function(T value)? onChanged;

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
      Future.delayed(Duration.zero, () => notify(val));
    }
  }

  /// Alias for [value] setter. Good for passing to a Future or Stream.
  void setValue(T val) => value = val;

  @protected
  @mustCallSuper
  void notify(T val) {
    if (onChanged != null) onChanged!(val);
    final tmp = _completer;
    _completer = Completer<T>();
    tmp.complete(val);
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
