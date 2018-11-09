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
            for _ in 0..<2 {
                list.remove(t)
                XCTAssertEqual(count(), tickets.count - idx - 1)
            }
        }
        XCTAssertTrue(list.isEmpty)
    }
    
    func testPerformance() {
        measure {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 100
            
            let range = (0..<10000)
            let addOperations = range.map { i in BlockOperation { self.list.append(i) } }
            let removeOperations = range.map { _ in BlockOperation { self.list.dropFirst() } }
            let operations = addOperations + removeOperations
            
            queue.addOperations(operations, waitUntilFinished: true)
        }
    }
    
    func testDispatchPerformance() {
        let syncQueue = DispatchQueue(label: "sync")
        var array = [Int]()
        
        let append: (Int) -> () = { i in
            syncQueue.sync {
                array.append(i)
            }
        }
        
        let remove: (Int) -> () = { i in
            syncQueue.sync {
                array.dropFirst()
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
