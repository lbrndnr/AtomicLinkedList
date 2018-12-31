//
//  AtomicStack.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 06.11.18.
//

import Foundation

final class AtomicStack<Element> {
    
    private var head = Node<Element>(element: nil)
    
    func push(_ node: Node<Element>) {
        var next: Node<Element>?
        
        repeat {
            next = head.next
            node.setNext(next: next, tag: .none)
        } while !head.CASNext(current: (next, .none), future: (node, .none))
    }
    
    func pop() -> Node<Element>? {
        var node: Node<Element>?
        var next: Node<Element>?
        
        repeat {
            node = head.next
            next = node?.next
        } while !head.CASNext(current: (node, .none), future: (next, .none))
        
        return node
    }
    
}
