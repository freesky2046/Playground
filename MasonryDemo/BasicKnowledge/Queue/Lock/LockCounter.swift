//
//  LockViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/4.
//

import UIKit

class LockCounter {
    private let lock = NSLock()
    private var num = 0.0
    
    func add() {
        lock.lock()
        self.num += 1
        lock.unlock()
    }
    
    func minus() {
        lock.lock()
        self.num -= 1
        lock.unlock()
    }
    
    func read() -> Double {
        var num = 0.0
        lock.lock()
        num = self.num
        lock.unlock()
        return num
    }
}
