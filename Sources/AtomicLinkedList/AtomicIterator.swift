//
//  AtomicIterator.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

import Foundation

public struct AtomicIterator<Element>: IteratorProtocol {
    
    private var node: Node<Element>
    private var removalQueue: DispatchQueue
    
    init(head: Node<Element>, removalQueue queue: DispatchQueue) {
        node = head
        removalQueue = queue
    }
    
    public mutating func next() -> Element? {
        guard let next = nextNode(of: node, removalQueue: removalQueue) else {
            return nil
        }
        
        node = next
        return node.element
    }
    
}

private func remove<E>(_ node: Node<E>, pred: Node<E>) {
    while pred.tag == .none && node.tag == .removed && pred.next === node {
        if pred.CASNext(current: (node, .none), future: (node.next, .none)) {
            return
        }
    }
}

private func nextNode<E>(of node: Node<E>, removalQueue: DispatchQueue) -> Node<E>? {
    if let next = node.next {
        if next.tag == .removed {
            defer {
                removalQueue.async {
                    remove(next, pred: node)
                }
            }
            return nextNode(of: next, removalQueue: removalQueue)
        }
        
        return next
    }
    
    return nil
}

func findTail<E>(from head: Node<E>, index: Int, removalQueue: DispatchQueue) -> (Int, Node<E>) {
    var idx = index
    var node = head
    
    while let next = nextNode(of: node, removalQueue: removalQueue) {
        node = next
        idx += 1
    }
    
    return (idx, node)
}

func findNode<E>(from head: Node<E>, with index: Int, condition: ((Int, E?) -> (Bool)), removalQueue: DispatchQueue) -> (Int, Node<E>)? {
    guard !condition(index, head.element) else {
        return (index, head)
    }
    
    var idx = index
    var node = head
    
    while let next = nextNode(of: node, removalQueue: removalQueue) {
        idx += 1
        node = next
        if condition(idx, node.element) {
            return (idx, node)
        }
    }
    
    return nil
}
