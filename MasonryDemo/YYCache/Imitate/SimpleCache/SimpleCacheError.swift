//
//  SimpleCacheError.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/3.
//

import Foundation

enum SimpleCacheError: Error {
    /// 1. 数据转换问题 (业务方传的对象有问题)
    /// - reason: 错误描述
    /// - underlying: 原始错误
    case serializationFailed(reason: String, underlying: Error?)
    
    /// 2. 磁盘/文件系统问题 (环境或权限问题)
    /// - reason: 错误描述
    /// - underlying: 原始错误
    case diskStorageFailed(reason: String, underlying: Error?)
    
    /// 3. 缓存逻辑问题 (已过期等)
    case expired
    
    /// 4. 未知/其他
    case unknown(underlying: Error?)
}
