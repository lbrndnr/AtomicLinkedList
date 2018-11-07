//
//  AtomicLinkedList.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

public final class AtomicLinkedList<Element> {
    
    private let pool = AtomicStack<Element>()
    
    private let head = Node<Element>()
    private var tail: Node<Element>
    
    public var isEmpty: Bool {
        return (head == tail)
    }
    
    // MARK: - Initialization
    
    public init() {
        tail = head
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
        let node = pool.pop() ?? Node()
        node.element = newElement
        
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
                p.next = nil
                t?.previous = nil
                tail = p
            }
        }
        else {
            if let previous = node.previous, let next = node.next {
                lock(previous, next) { p, n in
                    p.next = n
                    n?.previous = p
                }
            }
            else {
                assert(false)
            }
        }
        
        pool.push(node)
    }
    
    public func dropFirst() {
        guard let node = head.next else {
            return
        }
        
        remove(node)
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

extension AtomicLinkedList: Sequence {
    
    public func makeIterator() -> AtomicIterator<Element> {
        return AtomicIterator(head: head)
    }
    
}

extension AtomicLinkedList where Element: Equatable {
    
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
