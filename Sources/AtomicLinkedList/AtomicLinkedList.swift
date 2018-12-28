//
//  AtomicLinkedList.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

public final class AtomicLinkedList<Element> {
    
//    private let pool = AtomicStack<Element>()
    
    private let head = Node<Element>(element: nil)
    
    public var isEmpty: Bool {
        return head.next == nil || head.tag > 0
    }
    
    public func append(_ newElement: Element) {
        let node = Node(element: newElement)
        var tail: Node<Element>
        var iterator = AtomicIterator(head: head)
        
        repeat {
            iterator.reset(head: head)
            tail = iterator.findTail()
            node.setNext(next: nil, tag: 0)
        } while !tail.CASNext(current: (nil, 0), future: (node, 0))
    }
    
    // MARK: - Removal
    
    @discardableResult public func remove(at index: Int) -> Element? {
        var iterator = AtomicIterator(head: head)
        
        if let (_, node) = (iterator.find { i,_ in i == index }) {
            var next: Node<Element>?
            repeat {
                next = node.next
            } while !node.CASNext(current: (next, 0), future: (next, 1))
        }
        else {
            assert(false)
        }
        
        return nil
    }
    
    public func removeAll() {
        var next: Node<Element>?
        repeat {
            next = head.next
            if next == nil {
                return
            }
        }
        while !head.CASNext(current: (next, 0), future: (next, 1))
    }
    
}

extension AtomicLinkedList: Sequence {
    
    public func makeIterator() -> AtomicIterator<Element> {
        return AtomicIterator(head: head)
    }
    
}

extension AtomicLinkedList where Element: Equatable {
    
    public func remove(_ element: Element) {
        var iterator = AtomicIterator(head: head)
        while true {
            iterator.reset(head: head)
            if let (_, node) = (iterator.find { $1 == element }) {
                let next = node.next
                if node.CASNext(current: (next, 0), future: (next, 1)) {
                    break
                }
            }
            else {
                assert(false, "Could not find \(element)")
            }
        }
    }
    
}
