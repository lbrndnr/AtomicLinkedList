//
//  Node.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

import Atomics
import let  Darwin.libkern.OSAtomic.OS_SPINLOCK_INIT
import func Darwin.libkern.OSAtomic.OSSpinLockLock
import func Darwin.libkern.OSAtomic.OSSpinLockUnlock

private var IDCounter = AtomicUInt64()

final class Node<Element> {
    
    let ID: UInt64
    
    var element: Element?
    
    var previous: Node<Element>?
    var next: Node<Element>?
    
    private var spinlock = OS_SPINLOCK_INIT
    
    init() {
        ID = IDCounter.increment()
    }
    
    convenience init(element e: Element?) {
        self.init()
        element = e
    }
    
    func lock() {
//        print("lock \(ID)")
        OSSpinLockLock(&spinlock)
    }
    
    func unlock() {
//        print("unlock \(ID)")
        OSSpinLockUnlock(&spinlock)
    }
    
}

extension Node: Equatable {
    
    static func == (lhs: Node<Element>, rhs: Node<Element>) -> Bool {
        return lhs.ID == rhs.ID
    }
    
}

extension Node: Hashable {
    
    var hashValue: Int {
        return Int(ID)
    }
    
}

func order<E>(_ lhs: Node<E>, _ rhs: Node<E>?) -> (first: Node<E>, second: Node<E>?) {
    guard let rhs = rhs else {
        return (lhs, nil)
    }
    
    if lhs.ID < rhs.ID {
        return (lhs, rhs)
    }
    return (rhs, lhs)
}

func lock<E>(_ lhs: Node<E>, _ rhs: Node<E>?, during transaction: (Node<E>, Node<E>?) -> ()) {
    let (first, second) = order(lhs, rhs)
    
    first.lock()
    second?.lock()
    
    transaction(lhs, rhs)
    
    first.unlock()
    second?.unlock()
}
