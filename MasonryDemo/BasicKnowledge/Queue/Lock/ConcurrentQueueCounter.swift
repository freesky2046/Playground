//
//  QoncurrentQueueCounter.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/4.
//

import Foundation

class ConcurrentQueueCounter {
    private let queue = DispatchQueue(label: "com.queue.concurrent", attributes: .concurrent)
    private var num = 0.0
    
    func add() {
        queue.async(flags: .barrier) {
            self.num += 1
        }

    }
    
    func minus() {
        queue.async(flags: .barrier) {
            self.num -= 1
        }
    }
    
    func read() -> Double {
        var result = 0.0
        queue.sync {
            result = self.num
        }
        return result
    }
}
