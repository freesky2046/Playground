//
//  KingfisherBasicViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/4.
//

import UIKit
import Kingfisher

class KingfisherBasicViewController: UIViewController {
    
    var sampleImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var sampleImageView2: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // MARK: - ⚠️ 第一个参数
        // 1.遵从any Resource 协议 实际是URL,最终调用的Source参数
        let image = "https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png"
        let url: URL = URL(string:image)!
        view.addSubview(sampleImageView)
        sampleImageView.frame = CGRectMake(0, 200, 270, 125)
        sampleImageView.kf.setImage(with: url)
        
        // 2.Source对象
        let image2 = "https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png"
        let url2: URL = URL(string:image2)!
        let source: Source = Source.network(url2)
        view.addSubview(sampleImageView2)
        sampleImageView2.frame = CGRectMake(0, 400, 270, 125)
        sampleImageView2.kf.setImage(with: source)
        
        // MARK: - ⚠️ 回调参数
        // 回调
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let response):
                print("图片")
                print(response.image)
                print("缓存类型:枚举值 none|disk|memory")
                print(response.cacheType)
                print("来源:网络|本地")
                print(response.source)
                print("原始来源:网络|本地")
                print(response.originalSource)
                print("原始数据")
                print(response.data)
            case .failure(let error):
                print(error)
            }
        }
        
        
        
        
    }
    


}
