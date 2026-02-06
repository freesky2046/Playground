//
//  KingfisherBasicViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/4.
//

import UIKit
import Kingfisher
import SnapKit

class KingfisherBasicViewController: UIViewController {
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        return sv
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 30
        stack.alignment = .center
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Kingfisher Options Demo"
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.width.equalToSuperview()
        }
        
        let url = URL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-1.jpg")!
        
        // 1. 基础加载 (Basic)
        addDemo(title: "1. 基础加载",
                desc: "默认加载，无额外选项",
                url: url,
                options: nil)
        
        // 2. 过渡动画 (Transition)
        // .transition: 控制图片显示时的动画效果
        // 常用值: .fade(TimeInterval), .none
        addDemo(title: "2. 过渡动画 (Transition)",
                desc: ".transition(.fade(1.0)) - 渐变显示",
                url: url,
                options: [.transition(.fade(1.0)), .forceRefresh])
        
        // 3. 图片处理 (Processor)
        // .processor: 在缓存前对图片进行处理（圆角、模糊等）
        // 常用值: RoundCornerImageProcessor, BlurImageProcessor, ResizingImageProcessor
        let processor1 = RoundCornerImageProcessor(cornerRadius: 20)
        let processor2 = BlurImageProcessor(blurRadius: 100)
        addDemo(title: "3. 图片处理 (Processor)",
                desc: "RoundCornerImageProcessor(radius: 20) - 圆角",
                url: url,
                options: [.processor(processor2), .processor(processor1), .forceRefresh])
        
        // 4. 缓存控制 (Cache Control)
        // .cacheMemoryOnly: 只使用内存缓存，不存磁盘
        // .forceRefresh: 忽略缓存，强制网络请求
        // .fromMemoryCacheOrRefresh: 尝试内存，否则刷新（不读磁盘）
        addDemo(title: "4. 缓存控制 (Cache)",
                desc: ".cacheMemoryOnly & .forceRefresh",
                url: url,
                options: [.cacheMemoryOnly, .forceRefresh])
        
        // 5. 缩放 (Scale Factor)
        // .scaleFactor: 指定图片的缩放比例，默认为 1.0
        // 设置为 2.0 会让图片看起来更小（在高分屏上展示低分图时有用）
        addDemo(title: "5. 缩放因子 (Scale Factor)",
                desc: ".scaleFactor(2.0)",
                url: url,
                options: [.scaleFactor(2.0), .forceRefresh])
        
        // 6. 占位图 (Placeholder)
        // .placeholder: 加载过程中显示的占位内容（View 或 Image）
        // 这里模拟一个加载错误的 URL 来展示占位图（或者加载时间长）
        // 为了演示，我们还是用正常 URL 但加上 fade 动画能看到占位
        addDemo(title: "6. 占位图 (Placeholder)",
                desc: "加载中显示自定义 View/Image",
                url: url,
                options: [.transition(.fade(2.0)), .forceRefresh],
                showPlaceholder: true)
    }
    
    func addDemo(title: String, desc: String, url: URL, options: KingfisherOptionsInfo?, showPlaceholder: Bool = false) {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        
        let descLabel = UILabel()
        descLabel.text = desc
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .darkGray
        descLabel.numberOfLines = 0
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.clipsToBounds = true
        
        if showPlaceholder {
//            let placeholderLabel = UIImageView()
            let placeholderLabel = UIImage(named: "img")
            imageView.kf.setImage(with: url, placeholder: placeholderLabel, options: options)
        } else {
            imageView.kf.setImage(with: url, options: options)
        }
        
        container.addSubview(titleLabel)
        container.addSubview(descLabel)
        container.addSubview(imageView)
        
        stackView.addArrangedSubview(container)
        
        container.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(220)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
