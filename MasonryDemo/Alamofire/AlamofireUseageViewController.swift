//
//  AlamofireUseageViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/20.
//

import UIKit
import Alamofire

class AlamofireUseageViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        //
        
        // MARK: - ⚠️  请求
        /// 1. 发送请求: 非范型方法
        /// ,String是遵从URLConvertible协议的, 因此不是最后一个方法
        /// parameters为nil, 那么优选第一个非范型方法
        let dataRequest = AF.request("https://httpbin.org/get")
        
        
        // MARK: - ⚠️  响应
        
        /// 2.响应, 不做任何字节流转换
        ///  只要接口通了就是成功
        dataRequest.response { response in
            // 1. 发出去的原始请求 (URLRequest)
            // 包含最终的 URL、Header、Body
            print("Request: \(String(describing: response.request))")
            
            // 2. 收到的原始响应头 (HTTPURLResponse)
            // 包含 Status Code (200/404)、Response Headers
            print("Response: \(String(describing: response.response))")
            
            // 3. 收到的原始二进制数据 (Data)
            // 服务器返回的 Body，还未解析
            print("Data: \(String(describing: response.data))")
            
            // 4. 最终结果枚举 (Result<Data?, AFError>)
            // .success(Data?) 或 .failure(AFError)
            print("Result: \(response.result)")
            
            // 5. 解包后的成功值 (Data?)
            // 只有当 result 是 .success 时才有值，否则为 nil
            // 等价于 try? response.result.get()
            print("Value: \(String(describing: response.value))")
            
            // 6. 解包后的错误值 (AFError?)
            // 只有当 result 是 .failure 时才有值，否则为 nil
            print("Error: \(String(describing: response.error))")
        }
        
        /// 和 responseData高度类似, 只是如果返回原始数据为nil, 响应变为失败
        dataRequest.responseData { response in
            switch response.result {
            case .success(let data):
                print("字节流: \(data)")
            case .failure(let error):
                break
            }
        }
        
        
        /// 转换为字典或Array, 转换失败failure
        dataRequest.responseJSON { response in
            switch response.result {
            case .success(let res):
                print("字典:\(String(describing: res))")
            case .failure(let error):
                break
            }
        }
        
        dataRequest.responseString { response in
            switch response.result {
            case .success(let res):
                print("字符串:\(String(describing: res))")
            case .failure(let error):
                break
            }
        }
        
        /// 转换为模型, 转换失败failure
        dataRequest.responseDecodable(of: HResponse.self) { response in
            switch response.result {
            case .success(let res):
                print("模型:\(String(describing: res))")
            case .failure(let error):
                break
            }
        }
        
        
        // MARK: - ⚠️  字典/数组 参数编码
        
        // GET请求: value只能是简单的类型,参数无嵌套对象,url-encode
        // https://httpbin.org/get?name=zhangsan&age=25&city=beijing&gender=male
        let params: [String: String] = ["name": "zhang", "age": "25", "city": "beijing", "gender": "male"]
        let url = "https://httpbin.org/get"
        let dataRequst2 = AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil)
        dataRequst2.responseString { response in
            switch response.result {
            case .success(let res):
                print("get url-encode 后的res:\(res)")
            case .failure(let error):
                break
            }
        }
        

        let url2 = "https://httpbin.org/post"
        let complexParams: [String: Any] = [
            "user": [
                "name": "zhang",
                "age": 25,
                "profile": [
                    "gender": "male",
                    "bio": "iOS Developer"
                ]
            ],
            "tags": ["coding", "swift", "alamofire"], // 数组
            "addresses": [
                [
                    "type": "home",
                    "city": "Beijing",
                    "street": "Chaoyang Road"
                ],
                [
                    "type": "work",
                    "city": "Shanghai",
                    "street": "Nanjing Road"
                ]
            ]
        ]
        let dataRequst3 = AF.request(url2, method: .post, parameters: complexParams, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil)
        dataRequst3.responseString { response in
            switch response.result {
            case .success(let res):
                print("post 表单编码的res:\(res)")
            case .failure(let error):
                break
            }
        }
        
        
        let dataRequest4 = AF.request(url2, method: .post, parameters: complexParams, encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil)
        dataRequest4.responseString { response in
            switch response.result {
            case .success(let res):
                print("post json编码 后的res:\(res)")
            case .failure(let error):
                break
            }
        }
        
        // MARK: - ⚠️ Codable模型参数编码
        
        
    }

}

