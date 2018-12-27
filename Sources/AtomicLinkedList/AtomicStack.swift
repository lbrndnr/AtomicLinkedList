//
//  AtomicStack.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 06.11.18.
//

import Foundation

final class AtomicStack<Element> {
    
    private var head: Node<Element>?
    
    func push(_ node: Node<Element>) {
//        node.previous = nil
//        node.next = nil
        
//        lock(node, head) { n, h in
//            n.next = h
//            head = n
//        }
    }
    
    func pop() -> Node<Element>? {
        guard let node = head else {
            return nil
        }
        
//        lock(node, node.next) { h, n in
//            h.next = nil
//            head = n
//        }
        
        return node
    }
    
}
