//
//  AlamofireThirdViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/27.
//

import UIKit

class AlamofireThirdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        print("更多功能")
        // ✅
        print("1:可取消: NetworkManager外部调用方法返回值增加DataRequest")
        // ✅
        print("2.增加缓存管理能力")
        // ✅
        print("3.通用响应外壳: 将原来的T:Codable 换成一个BaseResponse<T>")
        // ✅
        print("4.日志:NetworkLogger, 1.在封装的NetworkManager中写拦截函数,利用Alamofire提供的类")
        // 
        print("3.多环境切换: 增加enum AppEnvironment 枚举")
    }

}
