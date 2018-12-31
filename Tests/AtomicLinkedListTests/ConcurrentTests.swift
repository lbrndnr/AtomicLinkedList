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
    
    private func performConcurrently(_ operations: [BlockOperation]) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        queue.addOperations(operations, waitUntilFinished: true)
    }
    
    // MARK: - Tests
    
    func testConcurrentPrepending() {
        let n = 10_000
        
        let operations = (0..<n).map { i in BlockOperation { self.list.prepend(i) } }
        performConcurrently(operations)
        
        XCTAssertEqual(count(), n)
    }

    func testConcurrentAppending() {
        let n = 10_000
        
        let operations = (0..<n).map { i in BlockOperation { self.list.append(i) } }
        performConcurrently(operations)
        
        XCTAssertEqual(count(), n)
    }
    
    func testConcurrentInsertion() {
        let n = 10_000
        let range = (0..<1000)
        for i in range {
            list.append(i)
        }
        XCTAssertEqual(Array(list), Array(range))
        
        let operations = (0..<n).map { i in BlockOperation {
            let idx = (i == 0) ? 0 : Int.random(in: 0 ..< 1000)
            self.list.insert(i, at: idx)
        }}
        performConcurrently(operations)
        
        XCTAssertEqual(count(), n + 1000)
    }
    
    func testConcurrentRemoval() {
        let n = 10_000
        let range = (0..<n)
        for i in range {
            list.append(i)
        }
        XCTAssertEqual(Array(list), Array(range))
        
        let operations = range.map { i in BlockOperation { self.list.remove(i) } }
                              .shuffled()
        performConcurrently(operations)
        
        XCTAssertEqual(count(), 0)
    }
    
    func testConcurrentAccess() {
        let n = 10_000
        let range = (0..<n)
        
        let operations = range.flatMap { i -> [BlockOperation] in
            let append = BlockOperation { self.list.append(i) }
            let remove = BlockOperation { self.list.remove(i) }
            remove.addDependency(append)
            
            return [append, remove]
        }.shuffled()
        performConcurrently(operations)
        
        XCTAssertEqual(count(), 0)
    }
    
}
