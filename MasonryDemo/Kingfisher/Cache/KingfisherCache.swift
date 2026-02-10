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
    
    func store(data: NSData, forKey key: String) {
        memoryCache.setObject(data, forKey: key as NSString)
    }
    
    func retrieveData(forKey key: String) -> NSData? {
        return memoryCache.object(forKey: key as NSString)
    }
}
