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
        guard let currentNode = node else {
            return nil
        }
        
        currentNode.lock()
        let nextNode = currentNode.next
        currentNode.unlock()
        
        node = nextNode
        return nextNode?.element
    }
    
}
