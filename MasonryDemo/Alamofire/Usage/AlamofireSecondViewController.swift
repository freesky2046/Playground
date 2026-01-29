//
//  AlamofireSecondViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/26.
//

import UIKit
import Alamofire

class AlamofireSecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        print("简单封装")
        print("1:路由化: APIRouter:见APIRouter, BinAPI")
        print("2.拦截器:处理公参和登陆: 见NetworkInterceptor, NetworkConfig")
        print("3.网络管理器:a.将请求,状态码验证,响应串联起来,业务只用调用一个方法, b.提供业务Response解包, c.请求前和响应后可以做一些公共处理, d.只将Data和Error上抛给业务方 // 见NetworkManager")
        let url = "https://gist.githubusercontent.com/freesky2046/c04f3621c4fd390aecd65cf76a5b002a/raw/82e39581afe12551ae1de79d40946d77cde33080/gistfile1.txt"
        NetworkManager.shared.sendCodable(url, method: .get, decodeType: BaseResponse<GistResponse>.self) { result in
            switch result {
            case .success(let res):
                print(res.data)
                print(res.data?.age)
                print(res.data?.name)
            case .failure(let failure):
                break
            }
        }
        
    }

}
