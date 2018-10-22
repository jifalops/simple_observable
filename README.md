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
