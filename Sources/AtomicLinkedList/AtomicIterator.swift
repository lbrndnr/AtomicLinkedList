//
//  AtomicIterator.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

public struct AtomicIterator<Element>: IteratorProtocol {
    
    private var node: Node<Element>
    
    init(head: Node<Element>) {
        node = head
    }
    
    public mutating func next() -> Element? {
        guard let next = nextNode(of: node) else {
            return nil
        }
        
        node = next
        return node.element
    }
    
}

private func removeIfTagged<E>(_ node: Node<E>, pred: Node<E>) -> Bool {
    while pred.tag == .none && node.tag == .removed && pred.next === node {
        if pred.CASNext(current: (node, .none), future: (node.next, .none)) {
            return true
        }
    }
    
    return false
}

private func nextNode<E>(of node: Node<E>) -> Node<E>? {
    if let next = node.next {
        if removeIfTagged(next, pred: node) {
            return nextNode(of: node)
        }
        
        return next
    }
    
    return nil
}

func findTail<E>(from head: Node<E>, index: Int) -> (Int, Node<E>) {
    var idx = index
    var node = head
    
    while let next = nextNode(of: node) {
        node = next
        idx += 1
    }
    
    return (idx, node)
}

func findNode<E>(from head: Node<E>, with index: Int, condition: ((Int, E?) -> (Bool))) -> (Int, Node<E>)? {
    guard !condition(index, head.element) else {
        return (index, head)
    }
    
    var idx = index
    var node = head
    
    while let next = nextNode(of: node) {
        idx += 1
        node = next
        if condition(idx, node.element) {
            return (idx, node)
        }
    }
    
    return nil
}
