import 'package:simple_observable/simple_observable.dart';

// See also https://pub.dev/packages/debounce_throttle

void main() async {
  final obs = Observable<int>(initialValue: 0, onChanged: printCallback);
  printFuture(obs);
  obs.values.listen(printStream);

  obs.value = 1;
  obs.value = 2;
  obs.value = 3;

  while (obs.value < 10) obs.value += 1;

  await Future.delayed(Duration.zero);
  print('========nullable========');
  withNullable();
}

void printCallback(int? value) => print('Callback: $value');
void printStream(int? value) => print('Stream: $value');
void printFuture(Observable obs) async {
  final value = await obs.nextValue;
  print('Future: $value');
  printFuture(obs);
}

void withNullable() {
  final obs = Observable<int?>(initialValue: null, onChanged: printCallback);
  printFuture(obs);
  obs.values.listen(printStream);

  obs.value = 1;
  obs.value = 2;
  obs.value = null;
  obs.value = 3;

  while (obs.value! < 10) obs.value = obs.value! + 1;
}

// Output:
//
// Callback: 1
// Future: 1
// Stream: 1
// Callback: 2
// Future: 2
// Stream: 2
// Callback: 3
// Future: 3
// Stream: 3
// Callback: 4
// Future: 4
// Stream: 4
// Callback: 5
// Future: 5
// Stream: 5
// Callback: 6
// Future: 6
// Stream: 6
// Callback: 7
// Future: 7
// Stream: 7
// Callback: 8
// Future: 8
// Stream: 8
// Callback: 9
// Future: 9
// Stream: 9
// Callback: 10
// Future: 10
// Stream: 10
