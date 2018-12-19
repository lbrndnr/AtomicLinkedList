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
        return true
//        return (head.next.load() === tail)
    }
    
    public func append(_ newElement: Element) {
        let node = Node(element: newElement)
        node.setNext(next: head.next, tag: 0)
        
        while !head.CASNext(current: head.next, future: node, currentTag: 0, futureTag: 0) {}
        
        //        let ticket = Ticket {
        //            weak var weakSelf = self
        //            weak var weakNode = node
        //
        //            guard let node = weakNode else {
        //                return
        //            }
        //
        //            weakSelf?.remove(node)
        //        }
        //
        //        return ticket
    }
    
    // MARK: - Removal
    
    private func remove(_ node: Node<Element>) {
        lock(node.previous!, node, node.next!) { p, c, n in
            p.next = n
            n.previous = p
        
            c.previous = nil
            c.next = nil
        }
    }
    
    public func dropFirst() -> Element? {
        guard let node = head.next else {
            return nil
        }
        
        let element = node.element
        remove(node)
        
        return element
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
            h.next = t
            t.previous = h
        }
    }
    
}

//extension AtomicLinkedList where Element: Comparable {
//
//    // MARK: - Insertion
//
//    public func append(_ newElement: Element) {
//        let node = Node(element: newElement)
//        while !tail.nextCAS(current: tail.next, future: node, currentTag: 0, futureTag: 0) {}
//
//        //        lock(tail.previous!, tail) { p, n in
//        //            node.previous = p
//        //            node.next = n
//        //
//        //            n.previous = node
//        //            p.next = node
//        //        }
//
//        //        let ticket = Ticket {
//        //            weak var weakSelf = self
//        //            weak var weakNode = node
//        //
//        //            guard let node = weakNode else {
//        //                return
//        //            }
//        //
//        //            weakSelf?.remove(node)
//        //        }
//        //
//        //        return ticket
//    }
//
//}

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
