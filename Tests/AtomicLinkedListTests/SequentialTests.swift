//
//  SequentialTests.swift
//  AtomicLinkedListTests
//
//  Created by Laurin Brandner on 23.10.18.
//

import XCTest
@testable import AtomicLinkedList

final class AtomicLinkedListTests: XCTestCase {
    
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
        for i in 0..<10 {
            list.append(i)
        }
        
        list.remove(5)
        XCTAssertEqual(count(), 9)
        
        list.remove(0)
        XCTAssertEqual(count(), 8)
        
        list.remove(9)
        XCTAssertEqual(count(), 7)
        
        list.removeAll()
        XCTAssertTrue(list.isEmpty)
    }
    
    func testTicket() {        
        var tickets = [Ticket]()
        for i in 0..<10 {
            let t = list.append(i)
            tickets.append(t)
        }
        XCTAssertFalse(list.isEmpty)
        
        tickets.shuffle()
        
        for (idx, t) in tickets.enumerated() {
            list.remove(t)
            XCTAssertEqual(count(), tickets.count-idx-1)
        }
        
        tickets.shuffle()
        
        for t in tickets {
            list.remove(t)
            XCTAssertEqual(count(), 0)
        }
        
        XCTAssertTrue(list.isEmpty)
    }
    
}
