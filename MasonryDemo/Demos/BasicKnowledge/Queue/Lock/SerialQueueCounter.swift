//
//  Counter.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/4.
//

import Foundation

class SerialQueueCounter {
    private let queue = DispatchQueue(label: "com.queue.serial")
    private var num = 0.0
    
    func add() {
        queue.async { // 若调用后马上需要使用num 就必须用sync
            self.num += 1
        }
    }
    
    func minus() {
        queue.async {
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
