import UIKit

// MARK: - Level 1: 基础协议 (类似 Java/OC 的 Interface)
// 协议只定义“你能做什么”，不关心“你是谁”
protocol Edible {
    var calories: Int { get } // 属性要求
    func eat()                // 方法要求
}

struct Apple: Edible {
    var calories: Int = 50
    func eat() {
        print("咔嚓一口，真脆！")
    }
}

class Pizza: Edible {
    var calories: Int = 300
    func eat() {
        print("拉丝芝士，真香！")
    }
}

// MARK: - Level 2: 协议扩展 (Protocol Extension) - 提供默认实现
// 这是 Swift 协议最强大的地方：可以给协议加默认代码！
protocol Flyable {
    var speed: Double { get }
    func fly()
}

// 只要你遵守了 Flyable，你就自动会 fly()，不用自己写
extension Flyable {
    func fly() {
        print("正在以 \(speed) km/h 的速度飞行")
    }
}

struct Bird: Flyable {
    var speed: Double = 20.0
    // 不需要写 fly()，自动获得！
}

struct Plane: Flyable {
    var speed: Double = 800.0
    // 也可以重写默认实现
    func fly() {
        print("引擎启动，以 \(speed) km/h 起飞！")
    }
}

// MARK: - Level 3: 关联类型 (Associated Type) - 泛型协议
// 协议里的“泛型”，让协议更灵活
protocol Container {
    associatedtype Item // 我不知道装着什么，你自己定
    var count: Int { get }
    mutating func append(_ item: Item)
    subscript(i: Int) -> Item { get }
}

// 存 Int 的盒子
struct IntStack: Container {
    typealias Item = Int // 明确告诉协议：我是存 Int 的
    
    private var items = [Int]()
    
    var count: Int { items.count }
    
    mutating func append(_ item: Int) {
        items.append(item)
    }
    
    subscript(i: Int) -> Int {
        return items[i]
    }
}

// 存 String 的盒子
struct StringStack: Container {
    // Swift 可以自动推断 Item 是 String，不用显式写 typealias
    private var items = [String]()
    
    var count: Int { items.count }
    
    mutating func append(_ item: String) {
        items.append(item)
    }
    
    subscript(i: Int) -> String {
        return items[i]
    }
}

// MARK: - Level 4: 协议组合 & 约束 (Protocol Composition & Constraints)
// 比如：一个函数要求参数必须“既能吃又能飞”
func superFunction(obj: Edible & Flyable) {
    obj.eat()
    obj.fly()
}

// 给数组扩展功能，但只针对遵守了 Edible 协议的元素
extension Array where Element: Edible {
    func totalCalories() -> Int {
        return self.reduce(0) { $0 + $1.calories }
    }
}

// MARK: - Level 5: 面向协议编程 (POP - Protocol Oriented Programming)
// 真正的 Swift 核心思想：优先用协议组合，而不是类继承
// 例子：游戏角色系统

protocol Attackable {
    func attack()
}

protocol Movable {
    func move()
}

protocol Healable {
    func heal()
}

// 扩展提供默认能力
extension Attackable {
    func attack() { print("普通攻击！") }
}

// 战士：能打能跑
struct Warrior: Attackable, Movable {
    func move() { print("冲锋！") }
}

// 法师：能打能奶
struct Mage: Attackable, Healable {
    func attack() { print("火球术！") }
    func heal() { print("治疗术！") }
}

// 演示控制器
class ProtocolDemoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Swift 协议详解"
        
        print("--- Level 1: 基础使用 ---")
        let apple = Apple()
        let pizza = Pizza()
        eatSomething(item: apple)
        eatSomething(item: pizza)
        
        print("\n--- Level 2: 默认实现 ---")
        let bird = Bird()
        let plane = Plane()
        bird.fly() // 默认实现
        plane.fly() // 自定义实现
        
        print("\n--- Level 3: 关联类型 ---")
        var intBox = IntStack()
        intBox.append(10)
        intBox.append(20)
        print("Int盒子数量: \(intBox.count)")
        
        print("\n--- Level 4: 协议约束 ---")
        let foods: [Apple] = [Apple(), Apple()]
        print("总卡路里: \(foods.totalCalories())") // 只有 Edible 数组才有这个方法
        
        print("\n--- Level 5: 面向协议编程 ---")
        let warrior = Warrior()
        warrior.attack()
        warrior.move()
        
        let mage = Mage()
        mage.attack()
        mage.heal()
    }
    
    func eatSomething(item: Edible) {
        print("正在吃卡路里为 \(item.calories) 的食物")
        item.eat()
    }
}
