
import Foundation

/// 使用 GCD Barrier 实现的读写分离缓存
/// 特点：读并发，写串行
class GCDSimpleCache<Key: Hashable, Value> {
    
    // 内部存储容器 (非线程安全，需要锁保护)
    private var storage: [Key: Value] = [:]
    
    // 并发队列: 允许多个读操作同时进行
    private let queue = DispatchQueue(label: "com.masonrydemo.gcdsimplecache", attributes: .concurrent)
    
    // MARK: - Read (Concurrent)
    
    /// 读取值
    /// 使用 sync 可以在当前线程同步获取结果
    /// 因为是 concurrent 队列，多个线程同时调用此方法时，block 可以并行执行（读并发）
    func value(forKey key: Key) -> Value? {
        var result: Value?
        queue.sync {
            result = storage[key]
        }
        return result
    }
    
    // MARK: - Write (Serial / Barrier)
    
    /// 写入值
    /// 使用 .barrier 标志，确保此时队列中只有这一个任务在执行（写串行/独占）
    /// 它会等待前面的读/写任务完成，然后独占执行，执行完后后续的任务才能继续
    func setValue(_ value: Value, forKey key: Key) {
        queue.async(flags: .barrier) {
            self.storage[key] = value
        }
    }
    
    /// 删除值
    /// 同样属于写操作，需要 barrier 保护
    func removeValue(forKey key: Key) {
        queue.async(flags: .barrier) {
            self.storage.removeValue(forKey: key)
        }
    }
}
