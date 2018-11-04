//
//  AtomicLinkedList.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

public final class AtomicLinkedList<Element> {
    
//    private let pool = AtomicStack<Node<Element>>()
    
    private let head = Node<Element>(element: nil)
    private var tail: Node<Element>
    
    public var isEmpty: Bool {
        return (head == tail)
    }
    
    // MARK: - Initialization
    
    public init() {
        tail = head
    }
    
    // MARK: - Lock
    
    private func order(_ lhs: Node<Element>, _ rhs: Node<Element>?) -> (first: Node<Element>, second: Node<Element>?) {
        guard let rhs = rhs else {
            return (lhs, nil)
        }
        
        if lhs.ID < rhs.ID {
            return (lhs, rhs)
        }
        return (rhs, lhs)
    }
    
    private func lock(_ lhs: Node<Element>, _ rhs: Node<Element>?, during transaction: (Node<Element>, Node<Element>?) -> ()) {
        let (first, second) = order(lhs, rhs)
        
        first.lock()
        second?.lock()
        
        transaction(lhs, rhs)
        
        first.unlock()
        second?.unlock()
    }
    
    // MARK: - Insertion
    
    @discardableResult public func append(_ newElement: Element) -> Ticket {
        let node = insert(newElement, previous: tail, next: tail.next)
        
        let ticket = Ticket {
            weak var weakSelf = self
            weak var weakNode = node

            guard let node = weakNode else {
                return
            }

            weakSelf?.remove(node)
        }
        
        return ticket
    }
    
//    public func insert(_ newElement: Element, at i: Int) {
//
//    }
    
    private func insert(_ newElement: Element, previous: Node<Element>, next: Node<Element>?) -> Node<Element> {
        let node = Node(element: newElement)
        
        lock(previous, next) { p, n in
            p.next = node
            node.previous = p
            node.next = n
            n?.previous = node
        }
        
        return node
    }
    
    // MARK: - Removal
    
    private func remove(_ node: Node<Element>) {
        if node == tail {
            lock(node.previous!, node) { p, t in
                tail = p
                p.next = nil
                t?.previous = nil
            }
        }
        else {
            if let previous = node.previous, let next = node.next {
                lock(previous, next) { p, n in
                    p.next = n
                    n?.previous = p
                }
            }
        }
    }
    
    public func remove(_ ticket: Ticket) {
        // TODO: check if the same list that issued the ticket
        ticket.block?()
        ticket.invalidate()
    }
    
    public func removeAll() {
        guard !isEmpty else {
            return
        }
        
        lock(head, tail) { h, t in
            h.next = nil
            t?.previous = nil
            tail = h
        }
    }
    
}

extension AtomicLinkedList : Sequence {
    
    public func makeIterator() -> AtomicIterator<Element> {
        return AtomicIterator(head: head)
    }
    
}

extension AtomicLinkedList where Element : Equatable {
    
    public func remove(_ element: Element) {
        var node = head
        while node.element != element, let next = node.next {
            node = next
        }
        
        if node.element == element {
            remove(node)
        }
    }
    
}
