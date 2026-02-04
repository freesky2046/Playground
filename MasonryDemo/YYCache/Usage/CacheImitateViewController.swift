//
//  CacheImitateViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/3.
//

import UIKit

class CacheImitateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // 读取本地.json
        let path = Bundle.main.path(forResource: "1", ofType: "json")!
        let jsonData = try! Data(contentsOf: URL(filePath: path))
        let json = String(data:jsonData, encoding: .utf8)
        print(jsonData.count)
        // 字符串的字节数, 一个json数据大概是几百字节到1000字节
        print(json?.utf8.count)
        
        let cache = SimpleCache(name: "NetworkJsonCache")
        let decoder = JSONDecoder()
        let res = try? decoder.decode(SimpleResponse.self, from: jsonData)
        cache.setObject(object: res, for: "home", cost: jsonData.count)
        let simple = cache.object(for: "home", as: SimpleResponse.self)
        print("读取成功:\(simple)")
        
        cache.removeAllObject()
        
        let simple2 = cache.object(for: "home", as: SimpleResponse.self)
        print(simple2?.data?.name)
        
    }
    
}

struct SimpleResponse: Codable {
    var code: Int?
    var msg: String?
    var data: SimpleData?
}

struct SimpleData: Codable {
    var name: String?
    var age: Int?
}
