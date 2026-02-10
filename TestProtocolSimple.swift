// 定义一个简单的类
class MyBaseClass {
    var name: String = "Base"
    
    func baseMethod() {
        print("Base method called")
    }
}

// 尝试定义一个继承自 MyBaseClass 的协议
protocol MyProtocol: MyBaseClass {
    func protocolMethod()
}

// 为协议提供默认实现
extension MyProtocol {
    func protocolMethod() {
        print("Protocol method called")
    }
}

// 测试类遵循协议
class MySubClass: MyBaseClass, MyProtocol {
    override func baseMethod() {
        print("Subclass base method called")
    }
}

// 测试使用
let obj = MySubClass()
obj.baseMethod()
obj.protocolMethod()
print(obj.name)
