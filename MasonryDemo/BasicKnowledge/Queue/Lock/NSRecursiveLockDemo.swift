import Foundation
import UIKit

class FileSizeCalculator {
    private let lock = NSRecursiveLock()
    private var totalSize: UInt64 = 0
    
    func calculateSize(at path: String) -> UInt64 {
        lock.lock()
        defer { lock.unlock() }
        
        var currentSize: UInt64 = 0
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            for item in contents {
                let itemPath = (path as NSString).appendingPathComponent(item)
                var isDirectory: ObjCBool = false
                
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // 递归遍历子目录
                        currentSize += calculateSize(at: itemPath)
                    } else {
                        // 计算文件大小：修正类型转换
                        let attributes = try fileManager.attributesOfItem(atPath: itemPath)
                        if let fileSizeNumber = attributes[FileAttributeKey.size] as? NSNumber {
                            currentSize += fileSizeNumber.uint64Value
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
        totalSize += currentSize
        return currentSize
    }
    
    func getTotalSize() -> UInt64 {
        lock.lock()
        defer { lock.unlock() }
        return totalSize
    }
}
