//
//  SimpleMemoryCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import Foundation

class SimpleMemoryCache {
    
    var totalCostLimit: Int  {
        get {
            cache.totalCostLimit
        }
        set {
            cache.totalCostLimit = newValue
        }
    }
    
    var countLimit: Int {
        get {
            cache.countLimit
        }
        set {
            cache.countLimit = newValue
        }
    }
    
    private(set) var name: String
    var cache: NSCache<NSString, AnyObject>

    init(name: String, totalCostLimit: Int = 50 * 1024 * 1024, countLimit: Int = 1000) {
        self.name = name
        cache = NSCache()
        self.totalCostLimit = totalCostLimit
        self.countLimit = countLimit
    }
    
    func setObject(object: any Codable, for key: String) {
        if let data = try? JSONEncoder().encode(object) {
            cache.setObject(data as AnyObject, forKey: key as NSString)
        }
    }
    
    func setObject(object: any Codable, for key: String, cost: Int)  {
        if let data = try? JSONEncoder().encode(object) {
            cache.setObject(data as AnyObject, forKey: key as NSString, cost: cost)
        }
    }
    
    func object<T: Codable>(for key: String, as type: T.Type) -> T? {
        if let data = cache.object(forKey: key as NSString) as? Data {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }
    
    func remove(object: any Codable, for key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func removeAllObject() {
        cache.removeAllObjects()
    }
    
}
