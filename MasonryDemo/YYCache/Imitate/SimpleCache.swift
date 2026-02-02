//
//  SimpleCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import Foundation

class SimpleCache {
    var diskCache: SimpleDiskCache
    var memoryCache: SimpleMemoryCache
    
    private(set) var name: String
    
    convenience init(name: String) {
        let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let URL = cache.appendingPathComponent(name)
        self.init(path: URL.path)
    }
   
    init(path: String) {
        let name = (path as NSString).lastPathComponent
        diskCache = SimpleDiskCache(path: path)
        memoryCache = SimpleMemoryCache(name: name)
        self.name = name
    }
    
    // 存
    func setObject(object: any Codable, for key: String) {
        diskCache.setObject(object: object, for: key)
        memoryCache.setObject(object: object, for: key)
    }
    
    // 取
    func object<T: Codable>(for key: String, as type: T.Type) -> T? {
        // 先从内存缓存读取
        if let data = memoryCache.cache.object(forKey: key as NSString) as? Data {
            if let object = try? JSONDecoder().decode(T.self, from: data) {
                return object
            }
        }
        
        // 内存缓存未找到，从磁盘缓存读取
        if let object = diskCache.object(for: key, as: T.self) {
            // 读取成功后，同步到内存缓存
            if let data = try? JSONEncoder().encode(object) {
                memoryCache.cache.setObject(data as AnyObject, forKey: key as NSString)
            }
            return object
        }
        
        return nil
    }
    
    // 删
    func remove(object: any Codable, for key: String) {
        diskCache.remove(object: object, for: key)
        memoryCache.remove(object: object, for: key)
    }
    

}
