//
//  AtomicIterator.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

public struct AtomicIterator<Element> {
    
    private var node: Node<Element>
    private var index: Int
    
    init(head: Node<Element>, index idx: Int = 0) {
        node = head
        index = idx
    }
    
    fileprivate func removeIfTagged(_ node: Node<Element>, pred: Node<Element>) -> Bool {
        while pred.tag == 0 && node.tag == 1 && pred.next === node {
            if pred.CASNext(current: (node, 0), future: (node.next, 0)) {
                return true
            }
        }
        
        return false
    }
    
    mutating func findTail() -> Node<Element> {
        while nextNode() != nil {}
        return node
    }
    
    mutating func find(with condition: ((Int, Element?) -> (Bool))?) -> (Int, Node<Element>)? {
        while let node = nextNode() {
            if let condition = condition, condition(index, node.element) {
                return (index, node)
            }
        }
        
        return nil
    }
    
    mutating func reset(head: Node<Element>, index idx: Int = 0) {
        node = head
        index = idx
    }
    
}

extension AtomicIterator: IteratorProtocol {
    
    public mutating func next() -> Element? {
        return nextNode()?.element
    }
    
    private mutating func nextNode() -> Node<Element>? {
        if let next = node.next {
            if removeIfTagged(next, pred: node) {
                return nextNode()
            }
            
            index += 1
            node = next
            return node
        }
        
        return nil
    }
    
}
