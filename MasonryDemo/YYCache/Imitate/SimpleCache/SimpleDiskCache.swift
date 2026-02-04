//
//  SimpleDiskCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import Foundation

class SimpleDiskCache {
    private(set) var path: String
    
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
    
    /// 这里实际上是一个文件夹下创建多个文件吧
    func setObject(object: any Codable, for key: String) throws {
        // 确保缓存目录存在
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            do {
                try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw SimpleCacheError.createDirectory(error: error)
            }
        }
        
        // 将对象转换为Data并存储
        var data: Data?
        do {
            try  data = JSONEncoder().encode(object)
        } catch {
            throw SimpleCacheError.encodeError(error: error)
        }
        
        if let data {
            let filePath = (self.path as NSString).appendingPathComponent(key.md5)
            do {
                try data.write(to: URL(fileURLWithPath: filePath))
                // 写入成功后，进行 LRU 清理
                PerformanceMeasurer.measureAndPrint("写入") {
                    trimRecursively()
                }
            } catch {
                throw SimpleCacheError.writeError(error: error)
            }
           
        }
    }
    
    func object<T: Codable>(for key: String, as type: T.Type) throws -> T? {
        let filePath = (self.path as NSString).appendingPathComponent(key.md5)
        let fileURL = URL(fileURLWithPath: filePath)
        var data: Data?
        do {
            try data = Data(contentsOf: fileURL)
            
            // 读取成功后，更新修改时间 (LRU 关键：标记为最近使用)
            try FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: filePath)
        } catch {
            throw SimpleCacheError.readError(error: error)
        }
        
        
        if let data   {
            let object: T?
            do {
                try object =  JSONDecoder().decode(T.self, from: data)
            } catch {
                throw SimpleCacheError.decodeError(error: error)
            }
            return object
        }
        return nil
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
    
    func remove(object: any Codable, for key: String) throws {
        let key = (self.path as NSString).appendingPathComponent(key.md5)
        do {
            try FileManager.default.removeItem(atPath: key)
        } catch {
            throw SimpleCacheError.removeError(error: error)
        }
       
    }
    
    func removeAllObject() throws {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            throw SimpleCacheError.removeError(error: error)
        }
        
        do {
            // 注意 还得重新创建一个目录
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw SimpleCacheError.createDirectory(error: error)
        }
    }
    
    func totalDiskSize() -> Int {
        let result =  FileManager.getDirectorySize(atPath: self.path)
        return Int(result)
    }

}
