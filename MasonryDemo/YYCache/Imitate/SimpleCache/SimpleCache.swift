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
    
    // 1. 创建串行队列 (Serial Queue)
    private let lock = DispatchQueue(label: "com.masonrydemo.simplecache.lock")
    
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
        // 串行队列保证操作顺序
        // 内存操作极快，使用 sync 不会造成卡顿
//        lock.sync {
            // 内存缓存同步写入
            self.memoryCache.setObject(object: object, for: key)
            
            // 磁盘缓存异步写入
            // 虽然 diskCache 内部是异步的，但我们在这里按顺序发起调用
            self.diskCache.setObject(object: object, for: key)
//        }
    }
    
    // 存: 大于1kb的用这个
    func setObject(object: any Codable, for key: String, cost: Int) {
//        lock.sync {
            self.memoryCache.setObject(object: object, for: key, cost: cost)
            self.diskCache.setObject(object: object, for: key)
//        }
    }
    
    // MARK: - fetch
    // 注意：现在的读取变成异步的了，所以返回值也必须是异步回调
    func object<T: Codable>(for key: String, as type: T.Type, completion: @escaping (T?) -> Void) {
        // 1. ⚡️ 快速路径：直接在当前线程读内存
        if let data = self.memoryCache.object(for: key, as: type) {
            completion(data)
            return
        }
        
        // 2. 🐢 慢速路径：内存没有，去排队读磁盘
        // 使用 sync 提交任务即可，因为内部的 diskCache.object 是异步的，不会阻塞
//        lock.sync {
            self.diskCache.object(for: key, as: type) { result in
                switch result {
                case .success(let object):
                    if let object = object {
                        // 3. 读到了，回填内存
                        // 直接操作 memoryCache 是安全的（NSCache 线程安全）
                        self.memoryCache.setObject(object: object, for: key)
                    }
                    completion(object)
                case .failure:
                    completion(nil)
                }
            }
//        }
    }
    
    // MARK: - delete
    func remove(for key: String) {
//        lock.sync {
            self.memoryCache.remove(forkey: key)
            self.diskCache.remove(for: key)
//        }
    }
    
    func removeAllObject() {
//        lock.sync {
            self.memoryCache.removeAllObject()
            self.diskCache.removeAllObject()
//        }
    }

}
