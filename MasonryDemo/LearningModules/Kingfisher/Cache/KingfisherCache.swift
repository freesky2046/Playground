//
//  KingfisherCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import Foundation

class KingfisherCache {
    // 简易内存缓存
    private let memoryCache = NSCache<NSString, NSData>()
    
    // 磁盘缓存
    private let diskCache: KingfisherDiskCache
    
    init(name: String) {
        self.diskCache = KingfisherDiskCache(name: name)
    }
    
    static let `default` = KingfisherCache(name: "com.masonrydemo.kingfisher.default")
    
    func store(data: NSData, forKey key: String) {
        memoryCache.setObject(data, forKey: key as NSString)
        // TODO: Store to disk
    }
    
    func retrieveData(forKey key: String) -> NSData? {
        return memoryCache.object(forKey: key as NSString)
        // TODO: Retrieve from disk if not in memory
    }
    
    // MARK: - Cache Size
    
    func calculateDiskStorageSize(completion: @escaping (UInt) -> Void) {
        diskCache.totalSize(completion: completion)
    }
}
