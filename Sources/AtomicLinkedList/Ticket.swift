//
//  Ticket.swift
//  AtomicLinkedList
//
//  Created by Laurin Brandner on 30.10.18.
//

import Foundation

public class Ticket {
    
    typealias Block = () -> ()
    
    var block: Block?
    
    let ID = UUID().uuidString
    
    var isValid: Bool {
        return block != nil
    }
    
    init(code: @escaping Block) {
        block = code
    }
    
    func invalidate() {
        block = nil
    }
    
}

extension Ticket : Equatable {
    
    public static func == (lhs: Ticket, rhs: Ticket) -> Bool {
        return lhs.ID == rhs.ID
    }
    
}

extension Ticket: Hashable {
    
    public var hashValue: Int {
        return ID.hashValue
    }
    
}
