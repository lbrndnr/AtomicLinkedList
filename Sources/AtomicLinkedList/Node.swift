//
//  Node.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

import Atomics

enum Tag: Int {
    case none = 0
    case removed = 1
}

final class Node<Element> {
    
    var element: Element?
    private var atomicNext = AtomicTaggedReference<Node<Element>>()
    
    var next: Node<Element>? {
        return atomicNext.load().ref
    }
    
    var tag: Tag {
        return Tag(rawValue: atomicNext.load().tag)!
    }
    
    init(element e: Element?) {
        element = e
    }
    
    func setNext(next: Node<Element>?, tag: Tag) {
        atomicNext.swap(next, tag: tag.rawValue)
    }
    
    @discardableResult func CASNext(current: (Node<Element>?, Tag), future: (Node<Element>?, Tag)) -> Bool {
        return atomicNext.CAS(current: (current.0, current.1.rawValue), future: (future.0, future.1.rawValue))
    }

}
