
import UIKit

class ThreadUnsafeDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "线程不安全示例 (慎点)"
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
        
        let buttons = [
            ("1. 数据竞争 (结果错误)", #selector(testDataRace)),
            ("2. 数组崩溃 (Crash)", #selector(testArrayCrash)),
            ("3. 字典崩溃 (Crash)", #selector(testDictionaryCrash))
        ]
        
        for (title, selector) in buttons {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.addTarget(self, action: selector, for: .touchUpInside)
            stack.addArrangedSubview(btn)
        }
        
        let tipLabel = UILabel()
        tipLabel.text = "⚠️ 注意：崩溃测试会导致 App 直接退出"
        tipLabel.textColor = .red
        tipLabel.font = .systemFont(ofSize: 12)
        stack.addArrangedSubview(tipLabel)
    }
    
    // MARK: - 1. 数据竞争 (Logic Error)
    // 现象：count 结果往往小于 10000，且每次运行结果不同。
    // 原因：`count += 1` 不是原子操作。它包含：读取 -> 加1 -> 写入。
    // 多线程同时读取到旧值，导致覆盖写入，丢失了累加次数。
    var count = 0
    @objc func testDataRace() {
        count = 0
        let group = DispatchGroup()
        print("🚀 开始测试数据竞争...")
        
        for _ in 0..<10000 {
            DispatchQueue.global().async(group: group) {
                // ❌ 线程不安全：多个线程同时读写
                self.count += 1
            }
        }
        
        group.notify(queue: .main) {
            print("❌ 期望值: 10000, 实际值: \(self.count)")
            if self.count != 10000 {
                print("😱 发生了数据竞争！丢失了 \(10000 - self.count) 次计算。")
            }
        }
    }
    
    // MARK: - 2. 数组并发修改 (Crash)
    // 现象：App 崩溃，报错 `EXC_BAD_ACCESS` 或 `EXC_BAD_INSTRUCTION`。
    // 原因：Swift 数组（Array）不是线程安全的。
    // 当多个线程同时扩容（reallocate）或写入内存时，会导致内存损坏。
    var unsafeArray: [Int] = []
    @objc func testArrayCrash() {
        unsafeArray = []
        print("🚀 开始测试数组崩溃...")
        
        for i in 0..<1000 {
            DispatchQueue.global().async {
                // ❌ 线程不安全：同时追加元素
                self.unsafeArray.append(i)
            }
        }
        print("🏃‍♂️ 任务已派发，请观察控制台或崩溃日志...")
    }
    
    // MARK: - 3. 字典并发修改 (Crash)
    // 现象：App 崩溃。
    // 原因：Swift 字典（Dictionary）同样不是线程安全的。
    // 内部哈希表在插入时需要重新哈希或扩容，多线程同时操作会破坏内部结构。
    var unsafeDict: [String: Int] = [:]
    @objc func testDictionaryCrash() {
        unsafeDict = [:]
        print("🚀 开始测试字典崩溃...")
        
        for i in 0..<1000 {
            DispatchQueue.global().async {
                // ❌ 线程不安全：同时写入键值对
                self.unsafeDict["key-\(i)"] = i
            }
        }
        print("🏃‍♂️ 任务已派发，请观察控制台或崩溃日志...")
    }
}
