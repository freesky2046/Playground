import Foundation

class CacheManager {
    static let shared = CacheManager()
    static let defaultMaxCacheAge: TimeInterval = 5 * 24 * 60 * 60 // 默认 5 天
    
    private var keyToRequestMap: [String: URLRequest] = [:]
    private let lock = NSLock()
    private let cache: URLCache
    
    private init() {
        // 内存缓存：10MB，磁盘缓存：50MB
        let memoryCapacity = 10 * 1024 * 1024
        let diskCapacity = 50 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        self.cache = urlCache
        // 注意：避免替换 URLCache.shared，除非明确需要全局影响
    }
    
    func store(request: URLRequest, response: URLResponse, data: Data, maxCacheAge: TimeInterval = defaultMaxCacheAge) {
        guard request.httpMethod?.lowercased() == "get" else { return }
        guard data.count > 0 else { return }
    
        let userInfo: [String: Any] = [
            "createTime": Date.timeIntervalSinceReferenceDate,
            "maxCacheAge": maxCacheAge
        ]
        
        let cachedResponse = CachedURLResponse(
            response: response,
            data: data,
            userInfo: userInfo,
            storagePolicy: .allowed
        )
        
        cache.storeCachedResponse(cachedResponse, for: request)
        
        let key = generateKey(urlRequest: request)
        lock.lock()
        keyToRequestMap[key] = request
        lock.unlock()
        
        // 存储后清理无效映射
        cleanupInvalidMappings()
    }
    
    func remove(request: URLRequest) {
        let key = generateKey(urlRequest: request)
        lock.lock()
        defer { lock.unlock() }
        
        if let storedRequest = keyToRequestMap[key] {
            cache.removeCachedResponse(for: storedRequest)
            keyToRequestMap.removeValue(forKey: key)
        }
    }
    
    func cachedData(request: URLRequest) -> Data? {
        // 读取前清理无效映射
        cleanupInvalidMappings()
        
        let key = generateKey(urlRequest: request)
        lock.lock()
        guard let storedRequest = keyToRequestMap[key] else {
            lock.unlock()
            return nil
        }
        lock.unlock()
        
        guard let cachedResponse = cache.cachedResponse(for: storedRequest),
              let userInfo = cachedResponse.userInfo,
              let createTime = userInfo["createTime"] as? TimeInterval,
              let maxCacheAge = userInfo["maxCacheAge"] as? TimeInterval else {
            return nil
        }
        
        let nowTime = Date.timeIntervalSinceReferenceDate
        if nowTime > createTime + maxCacheAge {
            remove(request: request)
            return nil
        }
     
        return cachedResponse.data
    }
    
    func generateKey(urlRequest: URLRequest) -> String {
        var result = urlRequest.url?.absoluteString ?? ""
        if let token = urlRequest.value(forHTTPHeaderField: "token"), !token.isEmpty {
            result += "_\(token)"
        }
        return result
    }
    
    func cleanupInvalidMappings() {
        lock.lock()
        defer { lock.unlock() }
        
        var validMappings: [String: URLRequest] = [:]
        for (key, request) in keyToRequestMap {
            if cache.cachedResponse(for: request) != nil {
                validMappings[key] = request
            }
        }
        keyToRequestMap = validMappings
    }
}
