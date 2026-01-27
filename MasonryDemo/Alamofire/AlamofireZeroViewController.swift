//
//  AlamofireFirstViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/22.
//

import UIKit
import Alamofire

class AlamofireZeroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        print("基础知识")
        
        let url = "https://httpbin.org/get"
        let URL1 = URL(string: url)!
        var request = URLRequest(url: URL1)
        // MARK: - ⚠️ URLRequest 支持原地修改(修改URL)
        let httpbinPostURLString = "https://httpbin.org/post"
        let URL2 = URL(string: httpbinPostURLString)!
        request.url = URL2

        
        // MARK: - ⚠️ URLComponents 又可以修改URL: 修改 percentEncodedQuery 就会自动修改components的URL
        let url3 = "https://httpbin.org/get?a=1"
        let URL3 = URL(string: url3)!
        var request1 = URLRequest(url: URL3)
        var components = URLComponents(url: request1.url!, resolvingAgainstBaseURL: false)!
        let query =  (components.percentEncodedQuery ?? "") + "&b=2"
        components.percentEncodedQuery = query
        request1.url = components.url
        print("修改已有的URL:\(request1.url)")
        
        // MARK: - ⚠️ URLComponents: 构建url 自动编码
        let url44: String = "httpbin.org/get"
        let URL44 = URL(string: url44)!
        var components22 = URLComponents(url: URL44, resolvingAgainstBaseURL: false)!
        components22.queryItems = [
            URLQueryItem(name: "name", value: "周"),
            URLQueryItem(name: "name", value: "明")
        ]
        let result = components22.url
        print("使用components22给URL添加参数:\(components22.url)")
        
        
        // MARK: - ⚠️ optional的 map 方法
        // Optional.map：仅当可选值不为 nil时，执行闭包中的转换逻辑；若为 nil，整个map调用直接返回nil；
        // 其中$0 是optional中包裹的值
        let URL4 = URL(string: url3)!
        var request2 = URLRequest(url: URL4)
        var components2 = URLComponents(url: request2.url!, resolvingAgainstBaseURL: false)!
        let query2 =  components2.percentEncodedQuery.map { $0 + "&" } ?? "" + "c=2"
        components2.percentEncodedQuery = query2
        request1.url = components2.url
        print("optional的 map:\(request1.url)")
        
        // MARK: - ⚠️ 字典按照key排序元祖转换
        let paramsss = ["name": "zhou", "age": "25", "sex": "male"]
        var tuples: [(String, String)] = []
        for key in paramsss.keys.sorted(by: <) {
            if let value = paramsss[key] {
                tuples.append((key, value))
            }
        }
        
        
        // MARK: - ⚠️ 编码 比较 系统内置的url-encode  set 和 af 的 url-encode
        let value = "明=!$&'()*+,;天"
//        urlQueryAllowed 是 CharacterSet 类型的预定义字符集，它包含了在 URL 查询字符串中被认为是安全的字符。当你使用 addingPercentEncoding(withAllowedCharacters:) 方法时，该方法会保留 urlQueryAllowed 中指定的字符，而对其他所有字符进行百分号编码。
//        具体来说，urlQueryAllowed 包含了以下字符：
//
//        字母（A-Z, a-z）
//        数字（0-9）
//        特殊安全字符：-、_、.、~
//        以及一些其他在 URL 查询中允许的字符
        let result2 = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
        print("😁使用系统的字符集白名单:\(result2) ")
        let result1 = value.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? value
        /// 对白名单进行裁剪,白名单更少,编码的值更多
        /// public static let afURLQueryAllowed: CharacterSet = {
        //        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        //        let subDelimitersToEncode = "!$&'()*+,;="
        //        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        //
        //        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
        //    }()
        print("😁使用裁剪后的字符集白名单:\(result1)")
     
    }
    
}


