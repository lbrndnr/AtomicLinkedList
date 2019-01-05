//
//  PerformanceTests.swift
//  AtomicLinkedListTests
//
//  Created by Laurin Brandner on 10.11.18.
//

import XCTest
@testable import AtomicLinkedList

@available(OSX 10.12, *)
class PerformanceTests: XCTestCase {

    typealias Function = (Int) -> ()
    typealias Operation = (fn: Function, n: Int)
    private func measure(insert: Operation, remove: Operation, contains: Operation, clear: (() -> ()), threads: Int) {
        precondition(remove.n <= insert.n)
        
        measureMetrics(PerformanceTests.defaultPerformanceMetrics, automaticallyStartMeasuring: false) {
            let insertions = (0..<insert.n).map { (insert.fn, $0) }
            let removals = (0..<remove.n).map { (remove.fn, $0) }
            let contains = (0..<contains.n).map { (contains.fn, $0) }
            let operations = (insertions + contains).shuffled()
            
            let semaphore = DispatchSemaphore(value: threads)
            let group = DispatchGroup()
            clear()
            
            startMeasuring()
            for op in operations {
                semaphore.wait()
                group.enter()
                Thread.detachNewThread {
                    op.0(op.1)
                    semaphore.signal()
                    group.leave()
                }
            }
            
            group.wait()
            stopMeasuring()
        }
    }

    func testListPerformance() {
        let list = AtomicLinkedList<Int>()
        let insert: Function = list.prepend
        let remove: Function = { list.remove($0) }
        let contains: Function = { _ = list.contains($0)}
        let clear = { print(Array(list).count) }
        
        measure(insert: (insert, 1_000), remove: (remove, 1_000), contains: (contains, 10_000), clear: clear, threads: 32)
    }
    
    func testBaseline() {
        let syncQueue = DispatchQueue(label: "sync")
        var array = [Int]()
        
        let insert: Function = { i in
            syncQueue.sync {
                array.append(i)
            }
        }
        
        let remove: Function = { i in
            syncQueue.sync {
                for (idx, j) in array.enumerated() {
                    if i == j {
                        array.remove(at: idx)
                        return
                    }
                }
//                array.removeAll { $0 == i }
            }
        }
        
        let contains: Function = { i in
            syncQueue.sync {
                _ = array.contains(i)
            }
        }
        
        let clear = { print(array.count) }
        
        measure(insert: (insert, 1_000), remove: (remove, 1_000), contains: (contains, 10_000), clear: clear, threads: 32)
    }

}
