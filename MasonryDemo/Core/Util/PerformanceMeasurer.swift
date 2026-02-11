import Foundation
import QuartzCore

class PerformanceMeasurer {
    
    /// 测量代码块的执行时间（秒）
    /// - Parameter block: 要执行的代码块
    /// - Returns: 执行时间（秒）
    static func measure<T>(_ block: () -> T) -> (result: T, time: TimeInterval) {
        let start = CACurrentMediaTime()
        let result = block()
        let end = CACurrentMediaTime()
        return (result, end - start)
    }
    
    /// 测量代码块的执行时间（秒）
    /// - Parameter block: 要执行的代码块
    /// - Returns: 执行时间（秒）
    static func measureExecutionTime(block: () -> Void) -> TimeInterval {
        let start = CACurrentMediaTime()
        block()
        let end = CACurrentMediaTime()
        return end - start
    }
    
    /// 测量代码块的执行时间并打印结果
    /// - Parameters:
    ///   - name: 操作名称
    ///   - block: 要执行的代码块
    static func measureAndPrint(_ name: String, block: () -> Void) {
        let time = measureExecutionTime(block: block)
        print("\(name) 执行时间: \(time) 秒")
    }
    
    /// 测量代码块的执行时间并打印结果（毫秒）
    /// - Parameters:
    ///   - name: 操作名称
    ///   - block: 要执行的代码块
    static func measureAndPrintMilliseconds(_ name: String, block: () -> Void) {
        let time = measureExecutionTime(block: block) * 1000
        print("\(name) 执行时间: \(time) 毫秒")
    }
    
    /// 测量代码块的执行时间并打印结果（微秒）
    /// - Parameters:
    ///   - name: 操作名称
    ///   - block: 要执行的代码块
    static func measureAndPrintMicroseconds(_ name: String, block: () -> Void) {
        let time = measureExecutionTime(block: block) * 1_000_000
        print("\(name) 执行时间: \(time) 微秒")
    }
}
