//
//  KingfisherManager.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import Foundation
import UIKit

struct RetrieveImageResult: Sendable {
//    var image: UIImage?
    var data: NSData?
    var cacheType: CacheType // 标识来源
}

// 简单的缓存类型枚举
enum CacheType: Sendable {
    case none
    case memory
    case disk
}

class KingfisherManager {
    // 单例模式，保证缓存共享
    static let shared = KingfisherManager()
    
    let downloader: KingfisherDownloader = KingfisherDownloader()
    let imageCache: KingfisherCache = KingfisherCache(name: "com.xx.xx")
    
    private init() { }
    
    func setImage(url: String, onComplete: @escaping (Result<RetrieveImageResult, KFError>) -> Void) {
        // 1. 核心思想：优先查询缓存
        // key 通常就是 URL
        if let cachedData = imageCache.retrieveData(forKey: url) {
            print("命中缓存: \(url)")
            let result = RetrieveImageResult(data: cachedData, cacheType: .memory)
            onComplete(.success(result))
            return
        }
        
        // 2. 缓存未命中，发起网络下载
        downloader.download(url: url) { [weak self] result in
            switch result {
            case .success(var imageResult):
                // 3. 下载成功后，写入缓存
                if let data = imageResult.data {
                    self?.imageCache.store(data: data, forKey: url)
                }
                // 标记来源为网络 (.none)
                imageResult.cacheType = .none
                onComplete(.success(imageResult))
                
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
