
import UIKit

class GCDCacheViewController: UIViewController {

    // 实例化缓存对象
    let cache = GCDSimpleCache<String, String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "GCD Barrier Cache Demo"
        
        setupUI()
        
        // 预先存一些数据
        for i in 0..<5 {
            cache.setValue("Value-\(i)", forKey: "Key-\(i)")
        }
    }
    
    func setupUI() {
        let btn = UIButton(type: .system)
        btn.setTitle("开始读写并发测试", for: .normal)
        btn.frame = CGRect(x: 50, y: 100, width: 200, height: 50)
        btn.addTarget(self, action: #selector(startTest), for: .touchUpInside)
        view.addSubview(btn)
        
        let label = UILabel(frame: CGRect(x: 20, y: 200, width: 300, height: 200))
        label.text = "请查看控制台输出\n观察读操作的并发性\n和写操作的独占性"
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
    }
    
    @objc func startTest() {
        print("🚀 开始测试...")
        
        // 模拟大量读操作 (并发)
        for i in 0..<10 {
            DispatchQueue.global().async {
                self.readTask(index: i)
            }
        }
        
        // 模拟写操作 (中间插入)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            self.writeTask(index: 99)
        }
        
        // 更多读操作
        for i in 10..<20 {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                self.readTask(index: i)
            }
        }
    }
    
    func readTask(index: Int) {
        let key = "Key-\(index % 5)"
        // 模拟耗时读取，更容易观察到并发
        print("📖 [读-开始] Thread: \(Thread.current) Index: \(index)")
        let value = cache.value(forKey: key)
        print("✅ [读-结束] Thread: \(Thread.current) Index: \(index) Value: \(value ?? "nil")")
    }
    
    func writeTask(index: Int) {
        print("✍️ [写-请求] Barrier 即将执行...")
        cache.setValue("NewValue-\(index)", forKey: "Key-0")
        // 注意：setValue 是 async barrier，这里为了演示效果，我们不能直接在 setValue 内部打印
        // 只能通过在 setValue 前后打印来观察提交时机
        // 真正的 barrier 执行时机是在 GCDSimpleCache 内部 block 执行的时候
        
        // 为了验证 barrier 确实阻塞了后续读取，我们可以再追加一个 barrier 任务用来打印
        cache.setValue("BarrierEnd", forKey: "Log") 
        print("✍️ [写-提交] Barrier 任务已提交")
    }
}
