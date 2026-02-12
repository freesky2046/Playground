
import UIKit
import os.lock

class LockBenchmarkViewController: UIViewController {
    
    // 循环次数
    let loops = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Swift 线程安全方案对比"
        
        setupUI()
    }
    
    func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let titles = ["1. NSLock", "2. Semaphore", "3. Serial Queue", "4. Barrier Queue", "5. OSAllocatedUnfairLock", "6. Actor", "7. @synchronized (Objc_sync)"]
        
        for (index, title) in titles.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.tag = index
            btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }
    }
    
    @objc func btnClick(_ sender: UIButton) {
        let tag = sender.tag
        print("\n🚀 开始测试: \(sender.title(for: .normal) ?? "")")
        
        switch tag {
        case 0: testNSLock()
        case 1: testSemaphore()
        case 2: testSerialQueue()
        case 3: testBarrierQueue()
        case 4: testUnfairLock()
        case 5: testActor()
        case 6: testObjcSync()
        default: break
        }
    }
    
    // MARK: - 1. NSLock (互斥锁)
    // 优点: API 简单，性能中等
    // 缺点: 无法防止死锁，必须成对调用 lock/unlock
    func testNSLock() {
        let lock = NSLock()
        var count = 0
        let group = DispatchGroup()
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<loops {
            DispatchQueue.global().async(group: group) {
                lock.lock()
                count += 1
                lock.unlock()
            }
        }
        
        group.notify(queue: .main) {
            let end = CFAbsoluteTimeGetCurrent()
            print("✅ NSLock 结果: \(count), 耗时: \(String(format: "%.4f", end - start))s")
        }
    }
    
    // MARK: - 2. DispatchSemaphore (信号量)
    // 优点: 可以控制并发数量，不仅是互斥
    // 缺点: 性能稍差，容易发生优先级反转
    func testSemaphore() {
        let semaphore = DispatchSemaphore(value: 1)
        var count = 0
        let group = DispatchGroup()
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<loops {
            DispatchQueue.global().async(group: group) {
                semaphore.wait()
                count += 1
                semaphore.signal()
            }
        }
        
        group.notify(queue: .main) {
            let end = CFAbsoluteTimeGetCurrent()
            print("✅ Semaphore 结果: \(count), 耗时: \(String(format: "%.4f", end - start))s")
        }
    }
    
    // MARK: - 3. Serial Queue (串行队列)
    // 优点: 纯 Swift 风格，避免死锁风险，逻辑清晰
    // 缺点: 涉及到线程切换，开销比纯锁大
    func testSerialQueue() {
        let queue = DispatchQueue(label: "com.test.serial")
        var count = 0
        let group = DispatchGroup()
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<loops {
            DispatchQueue.global().async(group: group) {
                // 必须用 sync 还是 async 取决于业务，这里为了计数准确性用 async 派发到串行队列
                queue.async {
                    count += 1
                }
            }
        }
        
        // 注意：这里需要在 queue 里的任务都执行完后才统计
        // 由于上面是 queue.async，group 的 notify 可能会早于 count 计算完触发
        // 所以我们这里的测试逻辑稍微调整：让 group enter/leave 包裹在 serial queue 内部
        
        let queueGroup = DispatchGroup()
        
        for _ in 0..<loops {
            queueGroup.enter()
            DispatchQueue.global().async {
                queue.async {
                    count += 1
                    queueGroup.leave()
                }
            }
        }
        
        queueGroup.notify(queue: .main) {
            let end = CFAbsoluteTimeGetCurrent()
            print("✅ SerialQueue 结果: \(count), 耗时: \(String(format: "%.4f", end - start))s")
        }
    }
    
    // MARK: - 4. Barrier Queue (并发队列 + 栅栏)
    // 优点: 读写分离，读效率高
    // 缺点: 只写不读的话，性能不如串行队列
    func testBarrierQueue() {
        let queue = DispatchQueue(label: "com.test.concurrent", attributes: .concurrent)
        var count = 0
        let group = DispatchGroup()
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<loops {
            DispatchQueue.global().async(group: group) {
                // 写操作用 barrier
                queue.async(flags: .barrier) {
                    count += 1
                }
            }
        }
        
        // 同样需要等待 barrier 执行完
        // 这里简化测试逻辑，直接用 group wait
        group.notify(queue: .main) {
            // 这里其实不严谨，因为 async barrier 可能还没跑完
            // 为了演示严谨性，我们追加一个 barrier 任务来读取最终结果
            queue.async(flags: .barrier) {
                let end = CFAbsoluteTimeGetCurrent()
                DispatchQueue.main.async {
                    print("✅ BarrierQueue 结果: \(count), 耗时: \(String(format: "%.4f", end - start))s")
                }
            }
        }
    }
    
    // MARK: - 5. OSAllocatedUnfairLock (iOS 16+)
    // 优点: 性能极高（用户态自旋锁），取代了废弃的 OSSpinLock
    // 缺点: iOS 16+ 才能用
    func testUnfairLock() {
        if #available(iOS 16.0, *) {
            let lock = OSAllocatedUnfairLock()
            var count = 0
            let group = DispatchGroup()
            
            let start = CFAbsoluteTimeGetCurrent()
            
            for _ in 0..<loops {
                DispatchQueue.global().async(group: group) {
                    lock.withLock {
                        count += 1
                    }
                }
            }
            
            group.notify(queue: .main) {
                let end = CFAbsoluteTimeGetCurrent()
                print("✅ UnfairLock 结果: \(count), 耗时: \(String(format: "%.4f", end - start))s")
            }
        } else {
            print("⚠️ UnfairLock 需要 iOS 16+")
        }
    }
    
    // MARK: - 6. Actor (Swift 5.5+)
    // 优点: 语言级别的线程安全，编译器检查，无死锁
    // 缺点: 异步上下文 (await)，稍微有些侵入性
    func testActor() {
        let counter = CounterActor()
        let group = DispatchGroup()
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<loops {
            group.enter()
            Task {
                await counter.increment()
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            Task {
                let finalCount = await counter.count
                let end = CFAbsoluteTimeGetCurrent()
                print("✅ Actor 结果: \(finalCount), 耗时: \(String(format: "%.4f", end - start))s")
            }
        }
    }
    
    // MARK: - 7. objc_sync_enter (互斥锁)
    // 优点: 类似于 Java 的 synchronized，简单
    // 缺点: 性能最差，不推荐使用
    func testObjcSync() {
        let lockObj = NSObject()
        var count = 0
        let group = DispatchGroup()
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<loops {
            DispatchQueue.global().async(group: group) {
                objc_sync_enter(lockObj)
                count += 1
                objc_sync_exit(lockObj)
            }
        }
        
        group.notify(queue: .main) {
            let end = CFAbsoluteTimeGetCurrent()
            print("✅ objc_sync 结果: \(count), 耗时: \(String(format: "%.4f", end - start))s")
        }
    }
}

// Actor 定义
actor CounterActor {
    var count = 0
    func increment() {
        count += 1
    }
}
