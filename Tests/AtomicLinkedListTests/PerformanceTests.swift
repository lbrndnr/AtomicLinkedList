//
//  PerformanceTests.swift
//  AtomicLinkedListTests
//
//  Created by Laurin Brandner on 10.11.18.
//

import XCTest
@testable import AtomicLinkedList

class PerformanceTests: XCTestCase {

    var list = AtomicLinkedList<Int>()
    
    // MARK: - Setup
    
    override func setUp() {
        list = AtomicLinkedList<Int>()
    }

    func testPerformance() {
        measure {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 100
            
            let range = (0..<10000)
            let addOperations = range.map { i in BlockOperation { self.list.append(i) } }
            let removeOperations = range.map { _ in BlockOperation { self.list.remove(at: 0) } }
            let operations = addOperations + removeOperations
            
            queue.addOperations(operations, waitUntilFinished: true)
        }
    }
    
    func testBaseline() {
        let syncQueue = DispatchQueue(label: "sync")
        var array = [Int]()
        
        let append: (Int) -> () = { i in
            syncQueue.sync {
                array.append(i)
            }
        }
        
        let remove: (Int) -> () = { i in
            syncQueue.sync {
                array.remove(at: 0)
            }
        }
        
        measure {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 100
            
            let range = (0..<10000)
            let addOperations = range.map { i in BlockOperation { append(i) } }
            let removeOperations = range.map { i in BlockOperation { remove(i) } }
            let operations = addOperations + removeOperations
            
            queue.addOperations(operations, waitUntilFinished: true)
        }
    }

}
