//
//  AtomicLinkedList.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 23.10.18.
//

import Atomics

public final class AtomicLinkedList<Element> {
    
//    private let pool = AtomicStack<Element>()
    
    private let head = Node<Element>(element: nil)
    private var estimatedTail: AtomicTaggedReference<Node<Element>>
    
    public var isEmpty: Bool {
        return head.next == nil || head.tag != .none
    }
    
    // MARK: - Initialization
    
    public init() {
        estimatedTail = AtomicTaggedReference(head, tag: 0)
    }
    
    public convenience init<S>(_ elements: S) where S: Sequence, Element == S.Element {
        self.init()
        
        let next = elements.reversed()
                           .reduce(nil as Node<Element>?) { n, e in
            let node = Node(element: e)
            node.setNext(next: n, tag: .none)
                 
            return node
        }
        
        head.setNext(next: next, tag: .none)
    }
    
    // MARK: - Insertion
    
    public func prepend(_ newElement: Element) {
        let node = Node(element: newElement)
        var next: Node<Element>?
        
        repeat {
            next = head.next
            node.setNext(next: next, tag: .none)
        } while !head.CASNext(current: (next, .none), future: (node, .none))
    }
    
    public func append(_ newElement: Element) {
        let node = Node(element: newElement)
        var tail: Node<Element>
        
        repeat {
            tail = getTail()
        } while !tail.CASNext(current: (nil, .none), future: (node, .none))
    }
    
    public func insert(_ newElement: Element, at index: Int) {
        let node = Node(element: newElement)
        var pred: Node<Element>
        var next: Node<Element>?
        
        repeat {
            guard let currentPred = getNode(at: index-1) else {
                preconditionFailure()
            }
            pred = currentPred
            next = pred.next
            node.setNext(next: next, tag: .none)
        } while !pred.CASNext(current: (next, .none), future: (node, .none))
    }
    
    // MARK: - Removal
    
    @discardableResult public func remove(at index: Int) -> Element? {
        if let node = getNode(at: index) {
            var next: Node<Element>?
            repeat {
                next = node.next
            } while !node.CASNext(current: (next, .none), future: (next, .removed))
        }
        else {
            preconditionFailure()
        }
        
        return nil
    }
    
    public func removeAll() {
        head.setNext(next: nil, tag: .none)
    }
    
    // MARK: - Reading
    
    public subscript(position: Int) -> Element {
        guard let node = getNode(at: position) else {
            preconditionFailure()
        }
        return node.element!
    }
    
    // MARK: -
    
    private func getTailEstimation() -> (ref: Node<Element>?, tag: Int) {
        let tail = estimatedTail.load()
        if tail.ref!.tag == .removed {
            estimatedTail.swap(head, tag: 0)
            return (head, 0)
        }
        
        return tail
    }
    
    private func updateTailEstimation(to node: Node<Element>, at index: Int) {
        var currentTail = estimatedTail.load()
        while node.tag == .none && (index > currentTail.tag || currentTail.ref!.tag == .removed) {
            if estimatedTail.CAS(current: currentTail, future: (node, index)) {
                break
            }
            currentTail = estimatedTail.load()
        }
    }

    private func getTail() -> Node<Element> {
        let currentTail = getTailEstimation()
        let (idx, node) = findTail(from: currentTail.ref!, index: currentTail.tag)
        updateTailEstimation(to: node, at: idx)
        
        return node
    }
    
    private func getNode(at position: Int) -> Node<Element>? {
        let currentTail = getTailEstimation()
        let start: Node<Element>
        let idx: Int
        
        if currentTail.tag <= position {
            start = currentTail.ref!
            idx = currentTail.tag
        }
        else {
            start = head
            idx = -1
        }
        
        return traverse(from: start, until: { i, _ in i == position }, with: idx)
    }
    
    private func traverse(from head: Node<Element>, until condition: ((Int, Element?) -> (Bool)), with index: Int = -1, updateTailEstimation update: Bool = true) -> Node<Element>? {
        let res = findNode(from: head, with: index, condition: condition)
        
        if let (idx, node) = res, update {
            updateTailEstimation(to: node, at: idx)
        }
        
        return res?.1
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
        while true {
            if let node = traverse(from: head, until: { $1 == element }, updateTailEstimation: false) {
                let next = node.next
                if node.CASNext(current: (next, .none), future: (next, .removed)) {
                    break
                }
            }
            else {
                preconditionFailure()
            }
        }
    }
    
}

extension AtomicLinkedList: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return Array(self).debugDescription
    }
    
}
