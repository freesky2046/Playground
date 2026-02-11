import UIKit
import ObjectiveC // 必须引入这个库，因为关联对象是 Runtime 特性

// MARK: - 1. 基础知识
/*
 为什么需要关联对象？
 Swift 的 Extension（扩展）通常只能添加计算属性 (Computed Property) 和方法，不能添加存储属性 (Stored Property)。
 如果你想给现有的类（比如 UIView）加一个用来存数据的变量，常规写法会报错。
 这时候就需要用到 Runtime 的关联对象技术，把数据“挂”到对象身上。
 */


// MARK: - 2. 给 UIView 添加一个 stringTag 属性
extension UIView {
    
    // 定义关联对象的 Key
    // (内存地址作为唯一标识)
    // 使用 Void? 或 UInt8 都可以，关键是地址要唯一
    private struct AssociatedObjectKeys { 
        static var kStringTagKey: UInt8 = 0
        static var kIsHighlightKey: UInt8 = 0
    }

    // 我们想在 Extension 里加一个 stored property，直接写 var stringTag: String? 会报错
    // 所以用计算属性 + 关联对象来实现
    var stringTag: String? {
        get {
            // 取值: 使用 key 获取关联的对象
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.kStringTagKey) as? String
        }
        set {
            // 存值: 将 newValue 关联到 self 上
            /*
             参数说明：
             1. object: 要挂载到的对象 (self)
             2. key: 唯一标识符的内存地址
             3. value: 要存储的值
             4. policy: 内存管理策略 (类似 @property 的修饰符)
                - .OBJC_ASSOCIATION_ASSIGN (assign, weak)
                - .OBJC_ASSOCIATION_RETAIN_NONATOMIC (strong, nonatomic) -> 最常用
                - .OBJC_ASSOCIATION_COPY_NONATOMIC (copy, nonatomic) -> 字符串/Block常用
                - .OBJC_ASSOCIATION_RETAIN (strong, atomic)
                - .OBJC_ASSOCIATION_COPY (copy, atomic)
             */
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kStringTagKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    // 技巧：提供默认值，避免 Optional
    // 比如我们想给 View 增加一个 "isHighlight" 标记，默认为 false
    var isHighlight: Bool {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedObjectKeys.kIsHighlightKey) as? Bool {
                return value
            }
            // 懒加载：如果没有值，设置初始值并返回
            let initialValue = false
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kIsHighlightKey, initialValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return initialValue
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kIsHighlightKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - 3. 实战案例：给 UIButton 添加闭包回调
// 这是一个非常经典的面试题和实用技巧：如何让 Button 支持 Block 点击？


extension UIButton {
    
    typealias ButtonTapAction = () -> Void

    private struct AssociatedObjectKeys {
        static var kTapActionKey: UInt8 = 0
    }

    // 添加一个闭包属性
    private var tapAction: ButtonTapAction? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.kTapActionKey) as? ButtonTapAction
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.kTapActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    // 公开的方法：添加点击回调
    func addTapBlock(_ action: @escaping ButtonTapAction) {
        self.tapAction = action
        // 添加 target-action
        self.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc private func handleTap() {
        // 执行闭包
        self.tapAction?()
    }
}



// MARK: - 演示控制器
class AssociatedObjectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "关联对象演示"
        
        setupDemo1()
        setupDemo2()
    }
    
    // 演示 1: 简单的属性存储
    func setupDemo1() {
        let testView = UIView()
        testView.backgroundColor = .red
        testView.frame = CGRect(x: 50, y: 100, width: 100, height: 100)
        view.addSubview(testView)
        
        // 就像使用普通属性一样使用关联对象
        testView.stringTag = "我是通过 Runtime 挂上去的标签"
        
        print("Demo 1 取值: \(testView.stringTag ?? "空")")
        
        // 点击 View 打印它的 tag
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        testView.addGestureRecognizer(tap)
    }
    
    @objc func viewTapped(_ gesture: UITapGestureRecognizer) {
        if let v = gesture.view {
            print("点击了 View, 它的 stringTag 是: \(v.stringTag ?? "")")
        }
    }
    
    // 演示 2: Button 的 Block 回调
    func setupDemo2() {
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 50, y: 250, width: 200, height: 50)
        btn.setTitle("点我执行 Block", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        view.addSubview(btn)
        
        // 使用我们扩展的方法
        btn.addTapBlock {
            print("Demo 2: 按钮被点击了！不再需要写 @objc func xxx 了！")
            
            // 还可以改颜色
            btn.backgroundColor = UIColor.randomColor()
        }
    }
}
