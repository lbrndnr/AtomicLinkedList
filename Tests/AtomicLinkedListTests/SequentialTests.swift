//
//  SequentialTests.swift
//  AtomicLinkedListTests
//
//  Created by Laurin Brandner on 23.10.18.
//

import XCTest
@testable import AtomicLinkedList

final class SequentialTests: XCTestCase {
    
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
    
    func testInitialization() {
        let ks = [1, 2, 3]
        list = AtomicLinkedList(ks)
        XCTAssertEqual(Array(list), ks)
    }
    
    func testEmptiness() {
        XCTAssertTrue(list.isEmpty)
        
        list.append(0)
        
        XCTAssertFalse(list.isEmpty)
    }
    
    func testInsertion() {
        let insertions: [Int] = Array(0 ..< 10)
        
        for i in insertions {
            list.append(i)
        }
        
        var actualInsertions = [Int]()
        for i in list {
            actualInsertions.append(i)
        }
        
        XCTAssertEqual(insertions, actualInsertions)
    }
    
    func testRemoval() {
        let range = 0..<10
        let allBut: ([Int]) -> ([Int]) = { ks in
            return Array(range).filter { !ks.contains($0) }
        }
        
        for i in range {
            list.append(i)
        }
        
        list.remove(5)
        XCTAssertEqual(Array(list), allBut([5]))
        
        list.remove(0)
        XCTAssertEqual(Array(list), allBut([5, 0]))
        
        list.remove(9)
        XCTAssertEqual(Array(list), allBut([5, 0, 9]))
        
        list.remove(at: 2)
        XCTAssertEqual(Array(list), allBut([5, 0, 9, 3]))
        
        list.remove(at: 3)
        XCTAssertEqual(Array(list), allBut([5, 0, 9, 3, 6]))
        
        list.removeAll()
        XCTAssertTrue(list.isEmpty)
    }
    
}
