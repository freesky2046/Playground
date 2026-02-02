//
//  SimpleMemoryCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import Foundation

class SimpleMemoryCache {
    var totalCostLimit: Int {
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

    init(name: String) {
        self.name = name
        cache = NSCache()
        
    }
    
    func setObject(object: any Codable, for key: String) {
        if let data = try? JSONEncoder().encode(object) {
            cache.setObject(data as AnyObject, forKey: key as NSString)
        }
    }
    
    func setObject(object: any Codable, for key: String, cost: Int) {
        if let data = try? JSONEncoder().encode(object) {
            cache.setObject(data as AnyObject, forKey: key as NSString, cost: cost)
        }
    }
    
    func remove(object: any Codable, for key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
}
