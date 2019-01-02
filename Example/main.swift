//
//  main.swift
//  Example
//
//  Created by Laurin Brandner on 02.01.19.
//

import Foundation
import AtomicLinkedList

let n = 10_000
let range = (0..<n)

var list = AtomicLinkedList<Int>()
let operations = range.flatMap { i -> [BlockOperation] in
    let append = BlockOperation { list.append(i) }
    let remove = BlockOperation { list.remove(i) }
    remove.addDependency(append)
    
    return [append, remove]
}.shuffled()

let queue = OperationQueue()
queue.maxConcurrentOperationCount = 100
queue.addOperations(operations, waitUntilFinished: true)
