//
//  SimpleCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import Foundation

class SimpleCache {
    private var diskCache: SimpleDiskCache
    private var memoryCache: SimpleMemoryCache
    private(set) var name: String
    private let queue = DispatchQueue(label: "com.simplecache.queue", attributes: .concurrent)
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
    
    // MARK: - save & update
    func setObject(object: any Codable, for key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.diskCache.setObject(object: object, for: key)
            self.memoryCache.setObject(object: object, for: key)
        }
    }
    
    // 存: 大于1kb的用这个
    func setObject(object: any Codable, for key: String, cost: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.diskCache.setObject(object: object, for: key)
            self.memoryCache.setObject(object: object, for: key, cost: cost)
        }
    }
    
    // MARK: - fetch
    func object<T: Codable>(for key: String, as type: T.Type) -> T? {
        var result: T?
        queue.sync { [weak self] in
            guard let self = self else { return }
            // 先从内存缓存读取
            if let data = self.memoryCache.object(for: key, as: type) {
                result = data
                return
            }
            
            // 内存缓存未找到，从磁盘缓存读取
            if let object = self.diskCache.object(for: key, as: type) {
                // 读取成功后，同步到内存缓存
                self.memoryCache.setObject(object: object, for: key)
                result = object
            }
        }
        return result
    }
    
    // MARK: - delete
    func remove(object: any Codable, for key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.diskCache.remove(object: object, for: key)
            self.memoryCache.remove(object: object, for: key)
        }
    }
    
    func removeAllObject() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.diskCache.removeAllObject()
            self.memoryCache.removeAllObject()
        }
    }

}
