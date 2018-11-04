//
//  atomicqueue.swift
//  QQ
//
//  Created by Guillaume Lessard on 2015-01-09.
//  Copyright (c) 2015 Guillaume Lessard. All rights reserved.
//

/// An interface for a node to be used with AtomicQueue (OSAtomicFifoQueue)
/// and AtomicStack (OSAtomicQueue).
/// The first bytes of the storage MUST be available for use as the link
/// pointer by `AtomicQueue.enqueue()` or `AtomicStack.push()`

//import func Darwin.libkern.OSAtomic.OSAtomicEnqueue
//import func Darwin.libkern.OSAtomic.OSAtomicDequeue
//
//protocol AtomicNode {
//    
////    associatedtype Element
//    
//    var storage: UnsafeMutableRawPointer { get }
////    var element: Element { get set }
//    
////    init(storage: UnsafeMutableRawPointer, element: Element)
//    init(storage: UnsafeMutableRawPointer)
//    
//}
//
//struct AtomicStack<Node: AtomicNode> {
//    
//    private let head: OpaquePointer
//    
//    init() {
//        // Initialize an OSQueueHead struct, even though we don't
//        // have the definition of it. See libkern/OSAtomic.h
//        //
//        //  typedef volatile struct {
//        //    void    *opaque1;
//        //    long     opaque2;
//        //  } __attribute__ ((aligned (16))) OSQueueHead;
//        
//        let size = MemoryLayout<OpaquePointer>.size
//        let count = 2
//        
//        let h = UnsafeMutableRawPointer.allocate(byteCount: count*size, alignment: 16)
//        for i in 0..<count {
//            h.storeBytes(of: nil, toByteOffset: i*size, as: Optional<OpaquePointer>.self)
//        }
//        
//        head = OpaquePointer(h)
//    }
//    
//    func deallocate() {
//        UnsafeMutableRawPointer(head).deallocate()
//    }
//    
//    func push(_ node: Node) {
//        OSAtomicEnqueue(head, node.storage, 0)
//    }
//    
//    func pop() -> Node? {
//        guard let bytes = OSAtomicDequeue(head, 0) else {
//            return nil
//        }
//        
//        return Node(storage: bytes)
//    }
//}
