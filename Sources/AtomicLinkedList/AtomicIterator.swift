//
//  AtomicIterator.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

public struct AtomicIterator<Element>: IteratorProtocol {
    
    private var node: Node<Element>?
    
    init(head: Node<Element>) {
        node = head
    }
    
    mutating public func next() -> Element? {
        guard let current = node else {
            return nil
        }
        
        node = current.next
        if current.tag > 0 {
            return next()
        }
        
        return node?.element
    }
    
}
