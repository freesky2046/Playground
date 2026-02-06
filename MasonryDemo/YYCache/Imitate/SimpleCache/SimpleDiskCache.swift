//
//  SimpleDiskCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import Foundation

class SimpleDiskCache {
    private(set) var path: String
    
    // 使用 Serial Queue 保证文件 IO 的线程安全
    private let queue = DispatchQueue(label: "com.masonrydemo.simplecache.disk", qos: .default)
    
    // MARK: - Limits
    /// 最大缓存数量限制 (默认无限制)
    var countLimit: Int = Int.max
    /// 最大磁盘空间限制 (默认 100MB)
    var costLimit: Int = 1024 * 1024 * 100
    
    init(path: String, countLimit: Int = Int.max, costLimit: Int = 1024 * 1024 * 100) {
        self.path = path
        self.countLimit = countLimit
        self.costLimit = costLimit
        // 预创建目录
        try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    
    /// 异步写入对象
    /// - Parameters:
    ///   - object: 要存储的对象
    ///   - key: 键
    ///   - completion: 完成回调 (Result<Void, Error>)
    func setObject(object: any Codable, for key: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        // 使用 async 不阻塞调用线程
        queue.async {
            do {
                // 1. 确保缓存目录存在
                var isDirectory: ObjCBool = false
                if !FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
                    do {
                        try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        throw SimpleCacheError.diskStorageFailed(reason: "Create directory failed", underlying: error)
                    }
                }
                
                // 2. 编码
                let data: Data
                do {
                    data = try JSONEncoder().encode(object)
                } catch {
                    throw SimpleCacheError.serializationFailed(reason: "Encode failed", underlying: error)
                }
                
                // 3. 写入文件
                let filePath = (self.path as NSString).appendingPathComponent(key.md5)
                do {
                    try data.write(to: URL(fileURLWithPath: filePath))
                    
                    // 4. 写入成功后，LRU 清理
                    PerformanceMeasurer.measureAndPrint("写入") {
                        self.trimRecursively()
                    }
                    
                    // 5. 成功回调
                    DispatchQueue.main.async {
                        completion?(.success(()))
                    }
                } catch {
                    throw SimpleCacheError.diskStorageFailed(reason: "Write file failed", underlying: error)
                }
            } catch {
                // 6. 失败回调
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }
    
    /// 异步读取对象
    /// - Parameters:
    ///   - key: 键
    ///   - type: 类型
    ///   - completion: 完成回调 (Result<T?, Error>)，在主线程回调
    func object<T: Codable>(for key: String, as type: T.Type, completion: @escaping (Result<T?, Error>) -> Void) {
        queue.async {
            let filePath = (self.path as NSString).appendingPathComponent(key.md5)
            let fileURL = URL(fileURLWithPath: filePath)
            
            // 1. 读取数据
            let data: Data
            do {
                data = try Data(contentsOf: fileURL)
                // 更新修改时间
                try FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: filePath)
            } catch {
                // 文件不存在不算错误，返回 nil
                DispatchQueue.main.async {
                    completion(.success(nil))
                }
                return
            }
            
            // 2. 解码
            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(SimpleCacheError.serializationFailed(reason: "Decode failed", underlying: error)))
                }
            }
        }
    }
    
    // MARK: - LRU & Trim
    
    /// 递归清理直到满足限制
    private func trimRecursively() {
        // 1. 检查是否需要清理
        let fileManager = FileManager.default
        let diskCacheURL = URL(fileURLWithPath: self.path)
        
        // 获取所有文件的属性 (URL, 资源值)
        guard let fileEnumerator = fileManager.enumerator(at: diskCacheURL,
                                                          includingPropertiesForKeys: [.contentModificationDateKey, .totalFileAllocatedSizeKey, .fileSizeKey],
                                                          options: .skipsHiddenFiles) else {
            return
        }
        
        var files: [SimpleDiskFile] = []
        var currentTotalSize: Int = 0
        
        for case let fileURL as URL in fileEnumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.contentModificationDateKey, .totalFileAllocatedSizeKey, .fileSizeKey])
                let modificationDate = resourceValues.contentModificationDate ?? Date.distantPast
                let fileSize = resourceValues.totalFileAllocatedSize ?? resourceValues.fileSize ?? 0
                
                currentTotalSize += fileSize
                files.append(SimpleDiskFile(url: fileURL, size: fileSize, modificationDate: modificationDate))
            } catch {
                print("Error getting resource values for \(fileURL): \(error)")
            }
        }
        
        // 如果没有超出限制，直接返回
        if files.count <= self.countLimit && currentTotalSize <= self.costLimit {
            return
        }
        
        // 2. 排序：按修改时间升序 (最旧的在前)
        // LRU 核心：淘汰最久未使用的
        files.sort { $0.modificationDate < $1.modificationDate }
        
        // 3. 开始清理
        var filesToDelete: [URL] = []
        
        // 清理直到满足 Count 限制
        while files.count > self.countLimit {
            if let file = files.first {
                filesToDelete.append(file.url)
                currentTotalSize -= file.size
                files.removeFirst()
            } else {
                break
            }
        }
        
        // 清理直到满足 Cost (大小) 限制
        while currentTotalSize > self.costLimit {
            if let file = files.first {
                filesToDelete.append(file.url)
                currentTotalSize -= file.size
                files.removeFirst()
            } else {
                break
            }
        }
        
        // 4. 执行删除
        for fileURL in filesToDelete {
            try? fileManager.removeItem(at: fileURL)
            // print("SimpleDiskCache trimmed: \(fileURL.lastPathComponent)")
        }
    }
    
    func remove(for key: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        queue.async {
            let filePath = (self.path as NSString).appendingPathComponent(key.md5)
            do {
                if FileManager.default.fileExists(atPath: filePath) {
                    try FileManager.default.removeItem(atPath: filePath)
                }
                DispatchQueue.main.async {
                    completion?(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func removeAllObject(completion: ((Result<Void, Error>) -> Void)? = nil) {
        queue.async {
            do {
                if FileManager.default.fileExists(atPath: self.path) {
                    try FileManager.default.removeItem(atPath: self.path)
                    try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
                }
                DispatchQueue.main.async {
                    completion?(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }

    }
    
    func removeAllObject(completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            do {
                if FileManager.default.fileExists(atPath: self.path) {
                    try FileManager.default.removeItem(atPath: self.path)
                    completion(.success(()))

                }
            } catch {
//                completion(.failure(SimpleCacheError.removeError(error: error)))
            }
            
            do {
                // 注意 还得重新创建一个目录
                try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
                completion(.success(()))
            } catch {
//                completion(.failure(SimpleCacheError.removeError(error:  SimpleCacheError.createDirectory(error: error))))
            }
        }
    }
    
    func totalDiskSize() -> Int {
        return queue.sync {
            let result =  FileManager.getDirectorySize(atPath: self.path)
            return Int(result)
        }
    }

}
