//
//  OnlySuperLock.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/10.
//

import Foundation
import UIKit

fileprivate class OnlySuperSimpleMemoryCache {
    private var storage: [String: Any] = [:] // Dictionary 非线程安全
    
    /// 设置值（无锁）
    func set(_ value: Any, forKey key: String) {
        print("SimpleMemoryCache: 设置值 for key: \(key), value: \(value)")
        storage[key] = value // 问题：可能被并发写入
    }
    
    /// 获取值（无锁）
    func get(forKey key: String) -> Any? {
        let value = storage[key] // 问题：可能被并发读取
        print("SimpleMemoryCache: 获取值 for key: \(key), value: \(value ?? "nil")")
        return value
    }
}

fileprivate class OnlySuperSimpleCache {
    private let lock = DispatchQueue(label: "com.masonrydemo.simplecache.lock")
    private var memoryCache: OnlySuperSimpleMemoryCache
    
    init() {
        self.memoryCache = OnlySuperSimpleMemoryCache()
    }
    
    /// 设置值（父缓存有锁）
    func set(_ value: Any, forKey key: String) {
        lock.sync {
            print("SimpleCache: 设置值 for key: \(key)")
            memoryCache.set(value, forKey: key) // 调用子缓存的无锁方法
        }
    }
    
    /// 获取值（父缓存有锁）
    func get(forKey key: String) -> Any? {
        return lock.sync {
            print("SimpleCache: 获取值 for key: \(key)")
            return memoryCache.get(forKey: key) // 调用子缓存的无锁方法
        }
    }
}

class OnlySuperLockViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "父有🔒,子无🔒"
        testCacheConcurrency()
    }
    
    func testCacheConcurrency() {
        let cache = OnlySuperSimpleCache()
        print("开始测试并发访问...")
        
        // 先加入的，先开始（Dequeue），但不一定先结束，也不一定先抢到锁。
        // 模拟 1000 个并发操作
        DispatchQueue.concurrentPerform(iterations: 1000) { index in
            print("线程:\(Thread.current)")
            let key = "key\(index % 10)" // 使用 10 个不同的键，增加并发冲突概率
            
            if index % 2 == 0 {
                // 写入操作
                cache.set("Value \(index)", forKey: key)
            } else {
                // 读取操作
                _ = cache.get(forKey: key)
            }
        }
        print("测试完成（如果程序未崩溃）")
    }

}

