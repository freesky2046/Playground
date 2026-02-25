import UIKit

class MemoryLeakDemoViewController: UIViewController {
    
    // MARK: - UI 组件
    private let stackView = UIStackView()
    private let memoryUsageLabel = UILabel()
    private var memoryTimer: Timer?
    
    // MARK: - 内存泄漏测试对象
    private var blockLeakObject: BlockLeakObject?
    private var timerLeakObject: TimerLeakObject?
    private var singletonLeakObject: SingletonLeakObject?
    private var delegateLeakObject: DelegateLeakObject?
    
    // MARK: - 大内存测试对象
    private var largeImage: UIImage?
    private var largeObjectArray: [LargeObject] = []
    private var unlimitedCache: [String: UIImage] = [:]
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startMemoryMonitoring()
        print("MemoryLeakDemoViewController initialized")
    }
    
    deinit {
        // 清理资源
        memoryTimer?.invalidate()
        blockLeakObject = nil
        timerLeakObject?.cleanup()
        timerLeakObject = nil
        singletonLeakObject = nil
        delegateLeakObject?.cleanup()
        delegateLeakObject = nil
        largeImage = nil
        largeObjectArray.removeAll()
        unlimitedCache.removeAll()
        LeakSingleton.shared.clearHeldObject()
        print("MemoryLeakDemoViewController deallocated")
    }
    
    // MARK: - UI 设置
    private func setupUI() {
        view.backgroundColor = .white
        title = "内存问题模拟"
        
        // 内存使用标签
        memoryUsageLabel.text = "内存使用: -- MB"
        memoryUsageLabel.textAlignment = .center
        memoryUsageLabel.font = .systemFont(ofSize: 16)
        memoryUsageLabel.backgroundColor = .lightGray
        memoryUsageLabel.textColor = .white
        memoryUsageLabel.layer.cornerRadius = 8
        memoryUsageLabel.clipsToBounds = true
        
        // 按钮设置
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        
        // 添加按钮
        let buttons = [
            ("Block 循环引用", #selector(testBlockLeak)),
            ("定时器未释放", #selector(testTimerLeak)),
            ("单例持有对象", #selector(testSingletonLeak)),
            ("Delegate 循环引用", #selector(testDelegateLeak)),
            ("加载大图片", #selector(testLargeImage)),
            ("大量对象创建", #selector(testLargeObjectCreation)),
            ("无限制内存缓存", #selector(testUnlimitedCache)),
            ("清理所有资源", #selector(cleanupAll))
        ]
        
        for (title, action) in buttons {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 8
            button.addTarget(self, action: action, for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            stackView.addArrangedSubview(button)
        }
        
        // 布局
        view.addSubview(memoryUsageLabel)
        view.addSubview(stackView)
        
        memoryUsageLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            memoryUsageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            memoryUsageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            memoryUsageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            memoryUsageLabel.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.topAnchor.constraint(equalTo: memoryUsageLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 内存监控
    private func startMemoryMonitoring() {
        memoryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }
    
    private func updateMemoryUsage() {
        let memory = getMemoryUsage() / 1024 / 1024  // 转换为 MB
        memoryUsageLabel.text = "内存使用: \(memory) MB"
        print("RunLoop: AfterWaiting (被唤醒 ⏰) ")
        print("RunLoop: BeforeTimers (处理Timer)")
    }
    
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return kerr == KERN_SUCCESS ? info.resident_size : 0
    }
    
    // MARK: - 内存泄漏测试方法
    @objc private func testBlockLeak() {
        print("=== 测试 Block 循环引用 ===")
        blockLeakObject = BlockLeakObject()
        blockLeakObject?.startLeak()
        // 注意：blockLeakObject 不会被释放，因为存在循环引用
    }
    
    @objc private func testTimerLeak() {
        print("=== 测试 定时器未释放 ===")
        timerLeakObject = TimerLeakObject()
        timerLeakObject?.startLeak()
        // 注意：timerLeakObject 不会被释放，因为定时器未 invalidate
    }
    
    @objc private func testSingletonLeak() {
        print("=== 测试 单例持有对象 ===")
        singletonLeakObject = SingletonLeakObject()
        LeakSingleton.shared.holdObject(singletonLeakObject!)
        // 注意：singletonLeakObject 不会被释放，因为被单例持有
    }
    
    @objc private func testDelegateLeak() {
        print("=== 测试 Delegate 循环引用 ===")
        delegateLeakObject = DelegateLeakObject()
        delegateLeakObject?.startLeak(with: self)
        // 注意：delegateLeakObject 不会被释放，因为存在 delegate 循环引用
    }
    
    // MARK: - 大内存使用测试方法
    @objc private func testLargeImage() {
        print("=== 测试 加载大图片 ===")
        // 模拟加载大图片（实际项目中应避免这种做法）
        UIGraphicsBeginImageContext(CGSize(width: 4000, height: 4000))
        UIColor.red.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 4000, height: 4000))
        largeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("大图片加载完成，尺寸: 4000x4000")
    }
    
    @objc private func testLargeObjectCreation() {
        print("=== 测试 大量对象创建 ===")
        // 清空之前的对象
        largeObjectArray.removeAll()
        
        // 创建 100,000 个大对象
        for i in 0..<100_000 {
            let largeObject = LargeObject(id: i)
            largeObjectArray.append(largeObject)
        }
        print("创建完成，对象数量: \(largeObjectArray.count)")
    }
    
    @objc private func testUnlimitedCache() {
        print("=== 测试 无限制内存缓存 ===")
        // 清空之前的缓存
        unlimitedCache.removeAll()
        
        // 缓存 100 张图片（每张 1MB 左右）
        for i in 0..<100 {
            // 创建 1000x1000 的图片
            UIGraphicsBeginImageContext(CGSize(width: 1000, height: 1000))
            UIColor(hue: CGFloat(i)/100, saturation: 1.0, brightness: 1.0, alpha: 1.0).setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: 1000, height: 1000))
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                unlimitedCache["image_\(i)"] = image
            }
            UIGraphicsEndImageContext()
        }
        print("缓存完成，图片数量: \(unlimitedCache.count)")
    }
    
    // MARK: - 清理方法
    @objc private func cleanupAll() {
        print("=== 清理所有资源 ===")
        
        // 清理内存泄漏对象
        blockLeakObject = nil
        timerLeakObject?.cleanup()
        timerLeakObject = nil
        singletonLeakObject = nil
        delegateLeakObject?.cleanup()
        delegateLeakObject = nil
        
        // 清理大内存对象
        largeImage = nil
        largeObjectArray.removeAll()
        unlimitedCache.removeAll()
        
        // 清理单例持有
        LeakSingleton.shared.clearHeldObject()
        
        print("所有资源已清理")
    }
}

// MARK: - 内存泄漏测试类

// 1. Block 循环引用测试
class BlockLeakObject {
    private var completion: (() -> Void)?
    
    func startLeak() {
        // 循环引用：self -> completion -> self
        completion = {
            print("Block executed, self: \(self)")
        }
        print("BlockLeakObject started leak")
    }
    
    deinit {
        print("BlockLeakObject deallocated")
    }
}

// 2. 定时器未释放测试
class TimerLeakObject {
    private var timer: Timer?
    
    func startLeak() {
        // 循环引用：timer -> self (target)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
        print("TimerLeakObject started leak")
    }
    
    func cleanup() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timerFire() {
        print("Timer fired")
    }
    
    deinit {
        cleanup()
        print("TimerLeakObject deallocated")
    }
}

// 3. 单例持有测试
class SingletonLeakObject {
    deinit {
        print("SingletonLeakObject deallocated")
    }
}

class LeakSingleton {
    static let shared = LeakSingleton()
    private var heldObject: AnyObject?
    
    func holdObject(_ object: AnyObject) {
        heldObject = object
        print("LeakSingleton holding object: \(object)")
    }
    
    func clearHeldObject() {
        heldObject = nil
        print("LeakSingleton cleared held object")
    }
    
    private init() {}
}

// 4. Delegate 循环引用测试
protocol LeakDelegate: AnyObject {}

class DelegateLeakObject {
    weak var delegate: LeakDelegate?
    
    func startLeak(with delegate: LeakDelegate) {
        // 注意：这里应该使用 weak，但为了测试循环引用，我们将在外部创建循环
        self.delegate = delegate
        print("DelegateLeakObject started leak")
    }
    
    func cleanup() {
        delegate = nil
    }
    
    deinit {
        print("DelegateLeakObject deallocated")
    }
}

// 扩展 MemoryLeakDemoViewController 以遵守 LeakDelegate（故意创建循环引用）
extension MemoryLeakDemoViewController: LeakDelegate {}

// MARK: - 大内存测试类

// 大对象测试
class LargeObject {
    private let id: Int
    private let largeData: Data
    
    init(id: Int) {
        self.id = id
        // 创建 10KB 的数据
        self.largeData = Data(repeating: 0, count: 10 * 1024)
    }
    
    deinit {
        // 仅在大量对象销毁时打印，避免日志过多
        if id % 10000 == 0 {
            print("LargeObject \(id) deallocated")
        }
    }
}
