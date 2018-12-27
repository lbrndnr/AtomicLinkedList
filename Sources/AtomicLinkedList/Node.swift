//
//  Node.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

import Atomics

final class Node<Element> {
    
    var element: Element?
    private var atomicNext = AtomicTaggedReference<Node<Element>>()
    
    var next: Node<Element>? {
        return atomicNext.load().ref
    }
    
    var tag: Int {
        return atomicNext.load().tag
    }
    
    init(element e: Element?) {
        element = e
    }
    
    func setNext(next: Node<Element>?, tag: Int) {
        atomicNext.swap(next, tag: tag)
    }
    
    @discardableResult func CASNext(current: (Node<Element>?, Int), future: (Node<Element>?, Int)) -> Bool {
        return atomicNext.CAS(current: current, future: future)
    }

}
