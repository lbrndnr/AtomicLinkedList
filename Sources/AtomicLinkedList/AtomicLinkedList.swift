//
//  AtomicLinkedList.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

public final class AtomicLinkedList<Element> {
    
    private let pool = AtomicStack<Element>()
    
    private let head = Node<Element>(element: nil)
    
    public var isEmpty: Bool {
        return head.next == nil || head.tag != .none
    }
    
    // MARK: - Initialization
    
    public init() {}
    
    public init<S>(_ elements: S) where S: Sequence, Element == S.Element {
        let next = elements.reversed()
                           .reduce(nil as Node<Element>?) { n, e in
            let node = Node(element: e)
            node.setNext(next: n, tag: .none)
                 
            return node
        }
        
        head.setNext(next: next, tag: .none)
    }
    
    // MARK: - Insertion
    
    private func popNode(with element: Element) -> Node<Element> {
        guard let node = pool.pop() else {
            return Node(element: element)
        }
        
        node.element = element
        return node
    }
    
    public func prepend(_ newElement: Element) {
        let node = popNode(with: newElement)
        var next: Node<Element>?
        
        repeat {
            next = head.next
            node.setNext(next: next, tag: .none)
        } while !head.CASNext(current: (next, .none), future: (node, .none))
    }
    
    public func append(_ newElement: Element) {
        let node = popNode(with: newElement)
        var tail: Node<Element>
        var iterator = AtomicIterator(head: head)
        
        repeat {
            iterator.reset(head: head)
            (_, tail) = iterator.findTail()
        } while !tail.CASNext(current: (nil, .none), future: (node, .none))
    }
    
    public func insert(_ newElement: Element, at index: Int) {
        let node = popNode(with: newElement)
        var pred: Node<Element>
        var next: Node<Element>?
        var iterator = AtomicIterator(head: head)
        
        repeat {
            iterator.reset(head: head)
            guard let (_, maybePred) = (iterator.find { i,_ in i == index-1 }) else {
                assert(false)
            }
            pred = maybePred
            next = pred.next
            node.setNext(next: next, tag: .none)
        } while !pred.CASNext(current: (next, .none), future: (node, .none))
    }
    
    // MARK: - Removal
    
    @discardableResult public func remove(at index: Int) -> Element? {
        var iterator = AtomicIterator(head: head)
        
        if let (_, node) = (iterator.find { i,_ in i == index }) {
            var next: Node<Element>?
            repeat {
                next = node.next
            } while !node.CASNext(current: (next, .none), future: (next, .removed))
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
        while !head.CASNext(current: (next, .none), future: (next, .removed))
    }
    
    // MARK: - Reading
    
    public subscript(position: Int) -> Element {
        var iterator = makeIterator()
        guard let (_, node) = (iterator.find { i,_ in i == position }) else {
            preconditionFailure()
        }
        return node.element!
    }
    
}

extension AtomicLinkedList: Sequence {
    
    public func makeIterator() -> AtomicIterator<Element> {
        return AtomicIterator(head: head)
    }
    
}

//extension AtomicLinkedList: Collection {
//    
//    public var startIndex: Int {
//        return 0
//    }
//    
//    public var endIndex: Int {
//        var iterator = makeIterator()
//        let (idx, _) = iterator.findTail()
//        return index(after: idx)
//    }
//    
//    public func index(after i: Int) -> Int {
//        return i+1
//    }
//    
//    public subscript(position: Int) -> Element {
//        var iterator = makeIterator()
//        guard let (_, node) = (iterator.find { i,_ in i == position }) else {
//            preconditionFailure()
//        }
//        return node.element!
//    }
//
//}

extension AtomicLinkedList where Element: Equatable {
    
    public func remove(_ element: Element) {
        var iterator = AtomicIterator(head: head)
        while true {
            iterator.reset(head: head)
            if let (_, node) = (iterator.find { $1 == element }) {
                let next = node.next
                if node.CASNext(current: (next, .none), future: (next, .removed)) {
                    break
                }
            }
            else {
                assert(false, "Could not find \(element)")
            }
        }
    }
    
}

extension AtomicLinkedList: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return Array(self).debugDescription
    }
    
}
