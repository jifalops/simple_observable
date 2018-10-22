import 'dart:async';
import 'package:simple_observable/simple_observable.dart';

void main() {
  /// Use of the SimpleObservable base class.
  final observable = SimpleObservable<String>(printCallback);
  observable.values.listen(printStream);

  /// Recursively listens to [nextValue] and prints changes.
  printFuture(observable);

  observable.value = 'a';
  observable.value = 'b';
  observable.value = 'c';

  /// Use of the Debouncer class.

  final debouncer =
      Debouncer<String>(Duration(milliseconds: 250), printCallback);
  debouncer.values.listen(printStream);
  printFuture(debouncer);

  /// Change the value multiple times before the debounce timer runs out.
  debouncer.value = '';
  final timer = Timer.periodic(Duration(milliseconds: 200), (_) {
    debouncer.value += 'x';
  });

  Future.delayed(Duration(milliseconds: 1000)).then((_) async {
    /// Cancels the above timer.
    timer.cancel();
    /// Make another change after the debouncer emits its value.
    await Future.delayed(Duration(milliseconds: 500));
    debouncer.value = 'hi';
  });

  // Multiple listeners are supported.
  debouncer.values.listen((value) => print('Stream2: $value'));
}

void printCallback(String value) => print('Callback: $value');
void printStream(String value) => print('Stream: $value');
void printFuture(SimpleObservable obs) => obs.nextValue.then((value) {
      print('Future: $value');
      printFuture(obs);
    });


// Output:
//
// Callback: a
// Future: a
// Stream: a
// Callback: b
// Future: b
// Stream: b
// Callback: c
// Future: c
// Stream: c
// Callback: xxxxx
// Future: xxxxx
// Stream: xxxxx
// Stream2: xxxxx
// Callback: hi
// Future: hi
// Stream: hi
// Stream2: hi