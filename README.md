# AtomicLinkedList

[![Twitter: @lbrndnr](https://img.shields.io/badge/contact-@lbrndnr-blue.svg?style=flat)](https://twitter.com/lbrndnr)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/lbrndnr/AtomicLinkedList/blob/master/LICENSE)

## About
This is an implementation of a lock-free singly linked list. It's fully thread-safe without relying on conventional locks. If used correctly, this makes it more performant and scale better. Moreover, the lack of locks makes it impossible to end up in a dead lock.
⚠️Note that this library is still WIP⚠️

## Usage
`AtomicLinkedList` can be used liked one would expect from a linked list. It currently conforms only to `Sequence` though, `Collection` will come once it's efficient enough.
The class provides multiple methods to modify its elements:
```swift
let list = AtomicLinkedList([1, 2, 3])
list.insert(10, at: 2)
list.append(4)
list.prepend(0)
list.remove(10) // or list.remove(at: 3)
print(list) // prints [0, 1, 2, 3, 4]
```

For now, `AtomicLinkedList` also implements a subscript method to read individual elements just like in a `Collection`:
```swift
print(list[1]) // prints 1
```

Since the entire class is thread safe, reading and writing to the list can be done from multiple threads.

## Dependencies
`AtomicLinkedList` is written in Swift and links against [Atomics](https://github.com/glessard/swift-atomics). 

## Author
I'm Laurin Brandner, I'm on [Twitter](https://twitter.com/lbrndnr).

## License
`AtomicLinkedList` is licensed under the [MIT License](http://opensource.org/licenses/mit-license.php).
