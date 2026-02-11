import UIKit
import YYCache

// 自定义Person类，需要遵循NSCoding协议
class Person: NSObject, NSCoding {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(age, forKey: "age")
    }
    
    required init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as? String ?? ""
        age = coder.decodeInteger(forKey: "age")
    }
}
 
extension CacheUsageViewController: RouteCompatible {
    
}

class CacheUsageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        // 创建缓存对象
        guard let cache: YYCache = YYCache(name: "CustomCache") else {
            return
        }
        
        // MARK: - ⚠️  增:基本对象
        cache.setObject("Hello YYCache" as NSCoding, forKey: "string")
        cache.setObject(42 as NSNumber, forKey: "number")
        cache.setObject(["a", "b", "c"] as NSArray, forKey: "array")
        cache.setObject(["key": "value"] as NSDictionary, forKey: "dictionary")
        
        // MARK: - ⚠️  增: 自定义对象
        let person: Person = Person(name: "ming", age: 19)
        cache.setObject(person, forKey: "person")
        
        // MARK: - ⚠️  查
        print(cache.object(forKey: "string")!)
        print(cache.object(forKey: "number")!)
        print(cache.object(forKey: "array")!)
        print(cache.object(forKey: "dictionary")!)
        let person2 = cache.object(forKey: "person") as! Person
        print(person2.name)
        print(person2.age)
        
        // MARK: - ⚠️  改: 更新缓存
        // 更新基本对象
        cache.setObject("Hello Updated YYCache" as NSCoding, forKey: "string")
        cache.setObject(99 as NSNumber, forKey: "number")
        
        // 更新自定义对象
        let updatedPerson: Person = Person(name: "updated ming", age: 20)
        cache.setObject(updatedPerson, forKey: "person")
        
        // 验证更新结果
        print("--- 更新后 ---")
        print(cache.object(forKey: "string")!)
        print(cache.object(forKey: "number")!)
        let person3 = cache.object(forKey: "person") as! Person
        print(person3.name)
        print(person3.age)
        
        // MARK: - ⚠️  删: 删除缓存
        // 删除单个缓存
        cache.removeObject(forKey: "string")
        print("--- 删除string后 ---")
        print("string exists:", cache.containsObject(forKey: "string"))

        
        // 删除所有缓存
        cache.removeAllObjects()
        print("--- 删除所有后 ---")
        print("dictionary exists:", cache.containsObject(forKey: "dictionary"))
        print("person exists:", cache.containsObject(forKey: "person"))
        
        
        // MARK: - ⚠️ 禁用内存缓存
        guard let cache33 : YYCache = YYCache(name: "FileCache") else {
            return
        }
        cache33.memoryCache.costLimit = 0 //  最大空间 总字节数
        cache33.memoryCache.countLimit = 0 // 最大数量
        cache33.memoryCache.ageLimit = 0 //  最长存活周期
        cache33.setObject(1 as NSNumber, forKey: "string")
    
        // MARK: - ⚠️ 设置内存限制
        guard let cache44 : YYCache = YYCache(name: "FileCache") else {
            return
        }
        cache44.memoryCache.costLimit = 1024 * 10  //  最大空间 10MB
        cache33.memoryCache.countLimit = 100 // 最大数量
        cache33.memoryCache.ageLimit = 0 //  最长存活周期
        cache33.setObject(1 as NSNumber, forKey: "string")
        
        
    }
}
