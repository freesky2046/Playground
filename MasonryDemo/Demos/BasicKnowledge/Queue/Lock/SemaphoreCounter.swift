//
//  LockCounter.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/4.
//

import Foundation

class SemaphoreCounter {
    private let lock = DispatchSemaphore(value: 1)
    private var num = 0.0
    
    func add() {
        lock.wait()
        defer {lock.signal() }
        self.num += 1
        
    }
    
    func minus() {
        lock.wait()
        defer {lock.signal() }
        self.num -= 1
        
    }
    
    func read() -> Double {
        lock.wait()
        defer {lock.signal() }
        return  self.num
    }
}
