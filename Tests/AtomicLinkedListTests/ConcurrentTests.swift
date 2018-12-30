//
//  ConcurrentTests.swift
//  AtomicLinkedListTests
//
//  Created by Laurin Brandner on 10.11.18.
//

import XCTest
@testable import AtomicLinkedList

class ConcurrentTests: XCTestCase {

    var list = AtomicLinkedList<Int>()
    
    // MARK: - Setup
    
    override func setUp() {
        list = AtomicLinkedList<Int>()
    }
    
    // MARK: - Helpers
    
    private func count() -> Int {
        var count = 0
        for _ in list {
            count += 1
        }
        
        return count
    }
    
    // MARK: - Tests
    
    func testConcurrentAppending() {
        let n = 10_000
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        let operations = (0..<n).map { i in BlockOperation { self.list.append(i) } }
                                .shuffled()
        queue.addOperations(operations, waitUntilFinished: true)
        
        XCTAssertEqual(count(), n)
    }
    
    func testConcurrentRemoval() {
        let n = 10_000
        let range = (0..<n)
        for i in range {
            list.append(i)
        }
        
        XCTAssertEqual(Array(list), Array(range))
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        let operations = range.map { i in BlockOperation { self.list.remove(i) } }
                              .shuffled()
        queue.addOperations(operations, waitUntilFinished: true)
        
        XCTAssertEqual(count(), 0)
    }
    
    func testConcurrentAccess() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        
        let range = (0..<1000)
        let insertionOperations = range.map { (false, $0) }
                                       .shuffled()
        var logicalOperations = insertionOperations
        for (idx, op) in insertionOperations.enumerated() {
            logicalOperations.insert((true, op.1), at: min(logicalOperations.count, 2*idx + 10))
        }
        
        // sanity check
        var inserted = Set<Int>()
        for (remove, idx) in logicalOperations {
            if remove {
                assert(inserted.contains(idx))
            }
            else {
                inserted.insert(idx)
            }
        }
        
        let operations = logicalOperations.map { op -> BlockOperation in
            if op.0 {
                return BlockOperation { self.list.remove(op.1) }
            }
            return BlockOperation { self.list.append(op.1) }
        }
        queue.addOperations(operations, waitUntilFinished: true)
        
        XCTAssertEqual(count(), 0)
    }
    
}
