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
    
    init(element e: Element?) {
        ID = IDCounter.increment()
        element = e
    }
    
    func lock() {
        OSSpinLockLock(&spinlock)
    }
    
    func unlock() {
        OSSpinLockUnlock(&spinlock)
    }
    
}

extension Node : Equatable {
    
    static func == (lhs: Node<Element>, rhs: Node<Element>) -> Bool {
        return lhs.ID == rhs.ID
    }
    
}

extension Node : Hashable {
    
    var hashValue: Int {
        return Int(ID)
    }
    
}
