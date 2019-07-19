# simple_observable

A debouncer and throttle that works with `Future`s, `Stream`s, and callbacks.

Class | Purpose
-|-
`Debouncer` | Wait for changes to stop before notifying.
`Throttle` | Notifies once per `Duration` for a value that keeps changing.
`SimpleObservable` | Base class for observing value changes.
