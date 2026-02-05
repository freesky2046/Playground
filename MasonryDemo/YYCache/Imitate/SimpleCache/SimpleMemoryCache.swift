//
//  SimpleMemoryCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import Foundation

// 内存缓存项，用于存储数据和过期时间
class MemoryCacheItem: NSObject {
    let data: Data
    let expiration: TimeInterval? // 过期时间（毫秒）
    let createdAt: TimeInterval // 创建时间（毫秒）
    
    init(data: Data, expiration: TimeInterval?) {
        self.data = data
        self.expiration = expiration
        self.createdAt = Date().timeIntervalSince1970 * 1000
    }
    
    // 检查是否过期
    func isExpired() -> Bool {
        guard let expiration = expiration else { return false }
        let now = Date().timeIntervalSince1970 * 1000
        return now > createdAt + expiration
    }
}

class SimpleMemoryCache {
    
    // NSCache 本身是线程安全的，不需要额外的锁来保护 object/setObject/removeObject 操作
    // 但如果我们需要保证 countLimit/totalCostLimit 的原子性或者组合操作的原子性，才需要锁
    // 在这个简单实现中，我们直接利用 NSCache 的线程安全性
    
    var totalCostLimit: Int  {
        get { cache.totalCostLimit }
        set { cache.totalCostLimit = newValue }
    }
    
    var countLimit: Int {
        get { cache.countLimit }
        set { cache.countLimit = newValue }
    }
    
    private(set) var name: String
    var cache: NSCache<NSString, AnyObject>

    init(name: String, totalCostLimit: Int = 50 * 1024 * 1024, countLimit: Int = 1000) {
        self.name = name
        cache = NSCache()
        self.totalCostLimit = totalCostLimit
        self.countLimit = countLimit
    }
    
    func setObject(object: any Codable, for key: String, expiration: TimeInterval? = nil) {
        if let data = try? JSONEncoder().encode(object) {
            let cacheItem = MemoryCacheItem(data: data, expiration: expiration)
            cache.setObject(cacheItem, forKey: key as NSString)
        }
    }
    
    func setObject(object: any Codable, for key: String, cost: Int, expiration: TimeInterval? = nil)  {
        if let data = try? JSONEncoder().encode(object) {
            let cacheItem = MemoryCacheItem(data: data, expiration: expiration)
            cache.setObject(cacheItem, forKey: key as NSString, cost: cost)
        }
    }
    
    func object<T: Codable>(for key: String, as type: T.Type) -> T? {
        let object = cache.object(forKey: key as NSString)
        
        // 处理 MemoryCacheItem 类型
        if let cacheItem = object as? MemoryCacheItem {
            // 检查是否过期
            if cacheItem.isExpired() {
                // 过期，从缓存中移除
                cache.removeObject(forKey: key as NSString)
                return nil
            }
            // 未过期，解码数据
            return try? JSONDecoder().decode(T.self, from: cacheItem.data)
        }
        
        // 兼容旧的 Data 类型（向后兼容）
        if let data = object as? Data {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        
        return nil
    }
    
    func remove(forkey: String) {
        cache.removeObject(forKey: forkey as NSString)
    }
    
    func removeAllObject() {
        cache.removeAllObjects()
    }
    
}
