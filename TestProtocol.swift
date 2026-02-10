import UIKit

// 测试协议继承自 UIViewController
protocol RouteCompatible: UIViewController {
    func handleParams(params: [String: String])
    static func customNavigation(params: [String: String]) -> Bool
}

// 为协议提供默认实现
extension RouteCompatible {
    func handleParams(params: [String: String]) {
        print("\(Self.self) 处理路由参数: \(params)")
    }
    
    static func customNavigation(params: [String: String]) -> Bool {
        false
    }
}

// 测试视图控制器遵循协议
class TestViewController: UIViewController, RouteCompatible {
    // 可以重写默认实现
    override func handleParams(params: [String: String]) {
        print("TestViewController 重写了 handleParams: \(params)")
    }
}

// 测试使用
let testVC = TestViewController()
testVC.handleParams(params: ["id": "123", "name": "test"])
let canNavigate = TestViewController.customNavigation(params: ["id": "123"])
print("是否可以自定义导航: \(canNavigate)")
