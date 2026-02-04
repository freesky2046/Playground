//
//  SimpleCacheError.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/3.
//

import Foundation

enum SimpleCacheError: Error {
    /// 编码
    case encodeError(error: Error)
    case decodeError(error: Error)
    
    /// 文件目录操作
    case createDirectory(error: Error)

    // 读写
    case readError(error: Error)
    case writeError(error: Error)
    case removeError(error: Error)
    
    case unknownError
}
