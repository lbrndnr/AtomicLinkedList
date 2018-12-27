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
        let range = (0..<1000)
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        let operations = range.map { i in BlockOperation { self.list.append(i) } }
                              .shuffled()
        queue.addOperations(operations, waitUntilFinished: true)
        
        XCTAssertEqual(count(), 1000)
    }
    
    func testConcurrentRemoval() {
        let range = (0..<1000)
        for i in range {
            list.append(i)
        }
        
        XCTAssertEqual(Array(list), Array(range))
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        let operations = range.map { i in BlockOperation { self.list.remove(i) } }
                              .shuffled()
        queue.addOperations(operations, waitUntilFinished: true)
        
        XCTAssertEqual(count(), 1000)
    }
    
    func testThreadSafety() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        
        let range = (0..<1000)
        let addOperations = range.map { i in BlockOperation { self.list.append(i) } }
        let removeOperations = range.map { i in BlockOperation { self.list.remove(at: 0) } }
        let operations = (addOperations).shuffled()
        
        queue.addOperations(operations, waitUntilFinished: true)
        
        XCTAssertEqual(count(), 0)
    }
    
}
