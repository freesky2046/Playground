//
//  KingfisherNetworkViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import UIKit

class KingfisherUseNetworkLayerViewController: UIViewController {
    lazy var imageView: UIImageView = UIImageView()
    lazy var imageView2: UIImageView = UIImageView()
    lazy var imageView3: UIImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor  = .white

        DispatchQueue.global(qos: .default).async {
            print("线程:\(Thread.current)")
            KingfisherManager.shared.retrieveImage(url: "https://picsum.photos/800/600") { result in
                switch result {
                case .success(let res):
                    if let data = res.data {
                        DispatchQueue.main.async(execute: {
                            self.imageView.image = UIImage(data: data as Data)
                        })
                    }
                case .failure(let failure):
                    print("error:\(failure)")
                }
            }
        }
   
        DispatchQueue.global(qos: .default).async {
            print("线程:\(Thread.current)")
            KingfisherManager.shared.retrieveImage(url: "https://picsum.photos/400/300") { result in
                switch result {
                case .success(let res):
                    if let data = res.data {
                        DispatchQueue.main.async(execute: {
                            self.imageView2.image = UIImage(data: data as Data)
                        })
                    }
                case .failure(let failure):
                    print("error:\(failure)")
                }
            }
        }
    
        DispatchQueue.global(qos: .default).async {
            print("线程:\(Thread.current)")
            KingfisherManager.shared.retrieveImage(url: "https://picsum.photos/200/500") { result in
                switch result {
                case .success(let res):
                    if let data = res.data {
                        DispatchQueue.main.async(execute: {
                            self.imageView3.image = UIImage(data: data as Data)
                        })
                    }
                case .failure(let failure):
                    print("error:\(failure)")
                }
            }
        }
    
        
        view.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 100, width: 32, height: 40)
        
        view.addSubview(imageView2)
        imageView2.frame = CGRect(x: 0, y: 150, width: 32, height: 40)
        
        view.addSubview(imageView3)
        imageView3.frame = CGRect(x: 0, y: 200, width: 32, height: 40)
        
        
    }
    



}
