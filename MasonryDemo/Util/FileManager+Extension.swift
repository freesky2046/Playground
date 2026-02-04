//
//  FileManager+Extension.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/3.
//

import Foundation

extension FileManager {
   static func getDirectorySize(atPath path: String) -> UInt64 {
        var totalSize: UInt64 = 0
        
        do {
            // 获取目录下的所有项目（文件和子目录）
            let items = try FileManager.default.contentsOfDirectory(atPath: path)
            
            for item in items {
                let itemPath = (path as NSString).appendingPathComponent(item)
                var isDirectory: ObjCBool = false
                
                // 检查是否为目录
                if FileManager.default.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // 递归计算子目录大小
                        totalSize += getDirectorySize(atPath: itemPath)
                    } else {
                        // 计算文件大小
                        if let attributes = try? FileManager.default.attributesOfItem(atPath: itemPath),
                           let size = attributes[.size] as? UInt64 {
                            totalSize += size
                        }
                    }
                }
            }
        } catch {
            print("获取目录大小失败：\(error)")
        }
        return totalSize
    }
}
