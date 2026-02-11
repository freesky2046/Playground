//
//  KingfisherDiskCache.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import Foundation

class KingfisherDiskCache {
    let fileManager = FileManager.default
    let diskCachePath: String
    
    init(name: String) {
        let cachePaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cachePath = cachePaths.first!
        diskCachePath = (cachePath as NSString).appendingPathComponent(name)
        
        createDirectory()
    }
    
    private func createDirectory() {
        if !fileManager.fileExists(atPath: diskCachePath) {
            do {
                try fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("KingfisherDiskCache create directory failed: \(error)")
            }
        }
    }
    
    // MARK: - Size Calculation
    
    /// Calculate total size of the cache folder
    func totalSize() -> UInt {
        var size: UInt = 0
        
        guard let fileEnumerator = fileManager.enumerator(atPath: diskCachePath) else {
            return 0
        }
        
        for fileName in fileEnumerator {
            guard let fileName = fileName as? String else { continue }
            let filePath = (diskCachePath as NSString).appendingPathComponent(fileName)
            
            do {
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                if let fileSize = attributes[.size] as? UInt {
                    size += fileSize
                }
            } catch {
                print("KingfisherDiskCache get file attributes failed: \(error)")
            }
        }
        
        return size
    }
    
    /// Calculate total size asynchronously
    func totalSize(completion: @escaping (UInt) -> Void) {
        DispatchQueue.global(qos: .default).async {
            let size = self.totalSize()
            DispatchQueue.main.async {
                completion(size)
            }
        }
    }
}
