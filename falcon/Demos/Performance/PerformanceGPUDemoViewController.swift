//
//  PerformanceGPUDemoViewController.swift
//  falcon
//
//  Created by falcon on 2026/02/13.
//

import UIKit
import SnapKit

class PerformanceGPUDemoViewController: UIViewController {

    private let indicatorView = UIView()
    private let fpsLabel = UILabel()
    private var displayLink: CADisplayLink?
    private var lastTime: TimeInterval = 0
    private var frameCount: Int = 0
    
    // 存储所有的“显卡杀手”视图，用于在每一帧强制刷新它们
    private var heavyViews: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Core Animation Demo (GPU)"
        
        setupUI()
        setupMonitor()
    }
    
    private func setupMonitor() {
        // 1. 悬浮的流畅度指示器 (Visual Smoothness Monitor)
        indicatorView.backgroundColor = .systemGreen
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        let dot = UIView()
        dot.backgroundColor = .white
        indicatorView.addSubview(dot)
        dot.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
        
        // 2. FPS 实时显示
        fpsLabel.text = "FPS: 60"
        fpsLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        fpsLabel.textColor = .systemGreen
        fpsLabel.textAlignment = .center
        fpsLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        fpsLabel.layer.cornerRadius = 5
        fpsLabel.layer.masksToBounds = true
        view.addSubview(fpsLabel)
        fpsLabel.snp.makeConstraints { make in
            make.top.equalTo(indicatorView.snp.bottom).offset(10)
            make.centerX.equalTo(indicatorView)
            make.width.equalTo(70)
        }
        
        startAnimation()
    }
    
    private func startAnimation() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(tick(link:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func tick(link: CADisplayLink) {
        // 1. 旋转动画 (保留视觉参考)
        indicatorView.transform = indicatorView.transform.rotated(by: 0.1)
        
        // 2. 强制重绘 (Simulate Heavy Animation)
        // 仅仅创建静态的阴影/混合图层，GPU 会有缓存，滑动时可能只是 Texture Mapping。
        // 为了真正打爆 GPU，我们让所有昂贵的 View 每一帧都发生微小变化 (Opacity/Shadow)，
        // 迫使 GPU 每一帧都必须重新计算高斯模糊和混合，无法复用缓存。
        // 配合 shouldRasterize = true，这会导致每一帧都触发 "Off-Screen Rasterization"
        let time = link.timestamp
        for (index, v) in heavyViews.enumerated() {
            // 改变透明度，迫使重新混合
            // 使用更剧烈的变化幅度
            v.alpha = 0.5 + 0.5 * CGFloat(sin(time * 10 + Double(index)))
            
            // 旋转一下，这对于 Rasterization 也是致命的（位图需要旋转重绘）
            v.transform = CGAffineTransform(rotationAngle: CGFloat(sin(time * 2 + Double(index)) * 0.05))
            
            // 如果是阴影视图，微调阴影半径，迫使重新计算 Blur
            if v.layer.shadowOpacity > 0 {
                v.layer.shadowRadius = 20 + 10 * CGFloat(sin(time * 10))
            }
        }
        
        // 3. FPS 计算
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        
        frameCount += 1
        let delta = link.timestamp - lastTime
        
        // 每秒更新一次 FPS
        if delta >= 1.0 {
            let fps = Double(frameCount) / delta
            fpsLabel.text = String(format: "FPS: %.0f", fps)
            
            // 掉帧变红
            if fps < 50 {
                fpsLabel.textColor = .red
                indicatorView.backgroundColor = .red
            } else {
                fpsLabel.textColor = .systemGreen
                indicatorView.backgroundColor = .systemGreen
            }
            
            lastTime = link.timestamp
            frameCount = 0
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: view.bounds.width, height: 2000)
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 说明
        let label = UILabel()
        label.text = "打开 Instruments -> Core Animation\n勾选 Color Blended Layers / Off-screen Rendered\n滑动页面观察 FPS"
        label.numberOfLines = 0
        label.textAlignment = .center
        stackView.addArrangedSubview(label)
        
        // 场景 1: 离屏渲染 (Off-Screen Rendering)
        // 圆角 + 阴影 + Mask
        addSectionTitle("1. 离屏渲染 (Off-Screen)", in: stackView)
        // 增加到 100 个
        for _ in 0..<100 {
            let v = createOffScreenView()
            stackView.addArrangedSubview(v)
            heavyViews.append(v)
            
            // ❌ 开启光栅化 + 动态修改 = 性能灾难
            // 这会强制 Core Animation 每一帧都把这个 View 渲染成一张位图
            // 极其消耗 GPU 显存带宽和光栅化资源
            v.layer.shouldRasterize = true
            v.layer.rasterizationScale = UIScreen.main.scale
        }
        
        // 场景 2: 混合图层 (Blended Layers)
        // 大量半透明叠加
        addSectionTitle("2. 混合图层 (200层叠加)", in: stackView)
        // 增加到 50 个
        for _ in 0..<50 {
            let v = createBlendedView()
            stackView.addArrangedSubview(v)
            heavyViews.append(v)
            // 同样开启光栅化滥用
            v.layer.shouldRasterize = true
            v.layer.rasterizationScale = UIScreen.main.scale
        }
        
        // 场景 3: 终极卡顿 - 巨型阴影
        addSectionTitle("3. 显卡杀手 (巨型阴影)", in: stackView)
        for _ in 0..<30 {
            let v = createHeavyShadowView()
            stackView.addArrangedSubview(v)
            heavyViews.append(v)
            // 开启光栅化
            v.layer.shouldRasterize = true
            v.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    private func createHeavyShadowView() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(100)
        }
        
        // 一个极其昂贵的阴影
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 0)
        v.layer.shadowOpacity = 1.0
        v.layer.shadowRadius = 20 // 半径越大越卡
        // 关键：不设置 shadowPath
        
        container.addSubview(v)
        v.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(80)
        }
        
        // 在阴影视图里加点半透明的东西
        let label = UILabel()
        label.text = "No ShadowPath + Radius 20"
        label.textColor = .red
        v.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return container
    }
    
    private func addSectionTitle(_ text: String, in stack: UIStackView) {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .darkGray
        stack.addArrangedSubview(label)
    }
    
    // MARK: - 1. 离屏渲染制造机
    private func createOffScreenView() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(60)
        }
        
        // ❌ 触发离屏渲染场景 1: 阴影没有 ShadowPath
        let shadowView = UIView()
        shadowView.backgroundColor = .white
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 5, height: 5)
        shadowView.layer.shadowOpacity = 0.8
        shadowView.layer.shadowRadius = 10
        // 关键点：不设置 shadowPath，GPU 需要离屏渲染来计算阴影形状
        
        container.addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.left.top.equalTo(10)
            make.width.height.equalTo(40)
        }
        
        // ❌ 触发离屏渲染场景 2: Mask (遮罩)
        let maskContainer = UIView()
        maskContainer.backgroundColor = .systemBlue
        
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.cornerRadius = 20 // 圆形遮罩
        
        maskContainer.layer.mask = maskLayer
        
        container.addSubview(maskContainer)
        maskContainer.snp.makeConstraints { make in
            make.left.equalTo(shadowView.snp.right).offset(20)
            make.top.equalTo(10)
            make.width.height.equalTo(40)
        }
        
        // ❌ 触发离屏渲染场景 3: cornerRadius + masksToBounds + 有子视图 (且子视图超出边界或有背景色)
        // 单纯的背景色 + cornerRadius 在 iOS 9+ 已经优化，不会离屏渲染。
        // 必须配合内容才行，比如给 layer 设置 contents (图片) 或者有子视图
        let radiusView = UIView()
        radiusView.backgroundColor = .systemGreen
        radiusView.layer.cornerRadius = 10
        radiusView.layer.masksToBounds = true
        
        let sub = UIView() // 子视图
        sub.frame = CGRect(x: -10, y: -10, width: 30, height: 30)
        sub.backgroundColor = .yellow
        radiusView.addSubview(sub)
        
        container.addSubview(radiusView)
        radiusView.snp.makeConstraints { make in
            make.left.equalTo(maskContainer.snp.right).offset(20)
            make.top.equalTo(10)
            make.width.height.equalTo(40)
        }
        
        return container
    }
    
    // MARK: - 2. 混合图层制造机
    private func createBlendedView() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(60)
        }
        
        // ❌ 背景透明
        container.backgroundColor = .clear
        
        // 叠加多层半透明 View (暴力增加到 200 层！)
        for i in 0..<200 {
            let v = UIView()
            // 随机位置，增加 GPU 绘制复杂度
            let x = Int.random(in: 0...100)
            let y = Int.random(in: 0...20)
            v.frame = CGRect(x: x, y: y, width: 200, height: 40)
            // ❌ alpha < 1.0 导致 GPU 混合
            v.backgroundColor = UIColor.randomColor().withAlphaComponent(0.1)
            container.addSubview(v)
        }
        
        // ❌ Label 背景透明，且中文文字也是一种 Mask
        let label = UILabel()
        label.text = "200层半透明叠加 👻"
        label.backgroundColor = .clear // 应该是 .white (如果想优化)
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return container
    }
    
    // MARK: - 3. 图片格式不齐 (Color Misaligned Images)
    private func createOversizedImageView() -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(100)
        }
        
        let iv = UIImageView()
        container.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        iv.contentMode = .scaleAspectFit // 拉伸模式
        // iv.clipsToBounds = true // 不需要裁剪也能看到 Misaligned
        
        // ❌ 制造一张巨大的图片 (2000x2000)，显示在 300x100 的 View 上
        // 这会导致 GPU 在渲染时进行缩放 (Resampling)
        // Instruments: Color Misaligned Images 会显示黄色 (Scaling)
        if let hugeImage = generateHugeImage() {
            iv.image = hugeImage
        }
        
        return container
    }
    
    private func generateHugeImage() -> UIImage? {
        let size = CGSize(width: 2000, height: 2000)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        UIColor.systemTeal.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // 画点东西
        let p = UIBezierPath(ovalIn: CGRect(x: 500, y: 500, width: 1000, height: 1000))
        UIColor.systemOrange.setFill()
        p.fill()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}


