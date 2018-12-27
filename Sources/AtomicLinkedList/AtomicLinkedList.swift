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
    
//    public func insert(_ newElement: Element, at index: Int) {
//        var i = 0;
//        var pred = head
//        var curr = head.next
//        while let node = curr, i < index  {
//            pred = node
//            curr = node.next
//            i += 1
//        }
//
//        let inserted  = insert(newElement, before: curr, after: pred)
//        if !inserted {
//            insert(newElement, at: index)
//        }
//    }
    
    public func append(_ newElement: Element) {
        let node = Node(element: newElement)
        var pred: Node<Element>
        
        repeat {
            (_, pred) = iterate()
            node.setNext(next: pred.next, tag: 0)
        } while !pred.CASNext(current: (nil, 0), future: (node, 0))
    }
    
    // MARK: - Removal
    
    @discardableResult public func remove(at index: Int) -> Element? {
        let (i, pred) = iterate { i,_ in i < index }
        
        if i == index {
            var next: Node<Element>?
            repeat {
                next = pred.next
            } while !pred.CASNext(current: (next, 0), future: (next, 1))
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
    
    // MARK: -
    
    private func iterate(with condition: ((Int, Element?) -> (Bool))? = nil) -> (Int, Node<Element>) {
        var i = 0
        var node = head
        removeNextIfTagged(of: node)
        while let next = node.next, (condition?(i, next.element) ?? true) {
            node = next
            i += 1
            removeNextIfTagged(of: node)
        }
        
        return (i, node)
    }
    
    internal func removeNextIfTagged(of node: Node<Element>) {
        while node.tag > 0 {
            var next: Node<Element>?
            repeat {
                next = node.next
            } while !node.CASNext(current: (next, 1), future: (next?.next, 0))
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
        let (_, pred) = iterate { $1 != element }
        
        if pred.next?.element == element {
            var next: Node<Element>?
            repeat {
                next = pred.next
            } while !pred.CASNext(current: (next, 0), future: (next, 1))
        }
        else {
            assert(false)
        }
    }
    
}
