//
//  SimpleDiskCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import Foundation

class SimpleDiskCache {
    private(set) var path: String
    
    init(path: String) {
        self.path = path
    }
    
    /// 这里实际上是一个文件夹下创建多个文件吧
    func setObject(object: any Codable, for key: String) {
        // 确保缓存目录存在
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            try? FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 将对象转换为Data并存储
        if let data = try? JSONEncoder().encode(object) {
            let filePath = (self.path as NSString).appendingPathComponent(key.md5)
            try? data.write(to: URL(fileURLWithPath: filePath))
        }
    }
    
    func object<T: Codable>(for key: String, as type: T.Type) -> T? {
        let filePath = (self.path as NSString).appendingPathComponent(key.md5)
        if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            if let object = try? JSONDecoder().decode(T.self, from: data) {
                return object
            }
        }
        return nil
    }
    
    func remove(object: any Codable, for key: String) {
        let key = (self.path as NSString).appendingPathComponent(key.md5)
        try? FileManager.default.removeItem(atPath: key)
    }
    
    func removeAllObject() {
        do {
            try FileManager.default.removeItem(atPath: path)
            // 注意 还得重新创建一个目录
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("err:\(error)")
        }
      
    }
}
