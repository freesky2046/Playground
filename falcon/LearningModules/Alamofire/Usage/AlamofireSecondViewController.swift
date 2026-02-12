//
//  AlamofireSecondViewController.swift
//  falcon
//
//  Created by 周明 on 2026/1/26.
//

import UIKit
import Alamofire
import SnapKit

class AlamofireSecondViewController: UIViewController {

    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14)
        tv.textColor = .black
        tv.isEditable = false
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.cornerRadius = 8
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Alamofire Second"
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        print("简单封装")
        print("1:路由化: APIRouter:见APIRouter, BinAPI")
        print("2.拦截器:处理公参和登陆: 见NetworkInterceptor, NetworkConfig")
        print("3.网络管理器:a.将请求,状态码验证,响应串联起来,业务只用调用一个方法, b.提供业务Response解包, c.请求前和响应后可以做一些公共处理, d.只将Data和Error上抛给业务方 // 见NetworkManager")
        
        // 原 URL 返回的是纯文本（Python 脚本），不是 JSON，无法使用 Codable 解析
        // 这里为了展示返回内容，改为直接请求 String
        let url = "https://gist.githubusercontent.com/freesky2046/c04f3621c4fd390aecd65cf76a5b002a/raw/82e39581afe12551ae1de79d40946d77cde33080/gistfile1.txt"
        
        NetworkManager.shared.request(url, method: .get).responseString { [weak self] response in
            guard let self = self else { return }
            
            var log = ""
            log += "⬇️ URL: \(url)\n\n"
            
            switch response.result {
            case .success(let str):
                log += "✅ Response String:\n\(str)"
            case .failure(let error):
                log += "❌ Error:\n\(error.localizedDescription)"
            }
            
            DispatchQueue.main.async {
                self.textView.text = log
            }
        }
    }

}
