//
//  AtomicTaggedReference.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 15.12.18.
//

import CAtomics
import Atomics

struct AtomicTaggedReference<T: AnyObject> {
    
    @usableFromInline internal var ptr = AtomicTaggedOptionalRawPointer()
    
    init(_ reference: T? = nil, tag: Int = 0) {
        initialize(reference, tag: tag)
    }
    
    mutating func initialize(_ reference: T?, tag: Int) {
        let u = reference.map(Unmanaged.passRetained)
        let tp = TaggedOptionalRawPointer(u?.toOpaque(), tag: tag)
        
        ptr.initialize(tp)
    }
    
    @discardableResult @inlinable mutating func swap(_ reference: T?, tag: Int, order: MemoryOrder = .sequential) -> (ref: T?, tag: Int) {
        let u = reference.map(Unmanaged.passRetained)
        let tp = TaggedOptionalRawPointer(u?.toOpaque(), tag: tag)
        
        let pointer = ptr.swap(tp, order)
        return (pointer.ptr.map(Unmanaged.fromOpaque)?.takeRetainedValue(), pointer.tag)
    }
    
//    @inlinable mutating func take(order: LoadMemoryOrder = .sequential) -> (ref: T, tag: Int) {
//        let pointer = ptr.spinSwap(nil, MemoryOrder(rawValue: order.rawValue)!)
//        return pointer.map(Unmanaged.fromOpaque)?.takeRetainedValue()
//    }
    
    @inlinable mutating func load(order: LoadMemoryOrder = .sequential) -> (ref: T?, tag: Int) {
        let tp = ptr.load(order)
        let u = tp.ptr.map(Unmanaged<T>.fromOpaque)
        return (u?.takeUnretainedValue(), tp.tag)
    }
    
    @inlinable mutating func CAS(current: T?, future: T?,
                                        currentTag: Int, futureTag: Int,
                                        type: CASType = .strong, order: MemoryOrder = .sequential) -> Bool {
        let cu = current.map(Unmanaged.passUnretained)
        let fu = future.map(Unmanaged.passUnretained)
        let ct = TaggedOptionalRawPointer(cu?.toOpaque(), tag: currentTag)
        let ft = TaggedOptionalRawPointer(fu?.toOpaque(), tag: futureTag)
    
        
        let success = ptr.CAS(ct, ft, type, order)
        if success {
            _ = fu?.retain()
            cu?.release()
        }
        
        return success
    }
}
