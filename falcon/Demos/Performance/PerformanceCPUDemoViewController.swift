//
//  PerformanceCPUDemoViewController.swift
//  falcon
//
//  Created by falcon on 2026/02/13.
//

import UIKit
import SnapKit

class PerformanceCPUDemoViewController: UIViewController {

    private let indicatorView = UIView()
    private let fpsLabel = UILabel()
    private var displayLink: CADisplayLink?
    private var lastTime: TimeInterval = 0
    private var frameCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Time Profiler Demo (CPU)"
        
        setupUI()
        startAnimation()
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    private func setupUI() {
        // 添加一个旋转指示器，用于肉眼观察卡顿
        // 如果主线程被阻塞，这个旋转动画会立刻停止
        indicatorView.backgroundColor = .systemRed
        // indicatorView.layer.cornerRadius = 25  // 移除圆角，方形旋转更明显
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        // 在红色方块上加个白色小点，让旋转更明显
        let dot = UIView()
        dot.backgroundColor = .white
        indicatorView.addSubview(dot)
        dot.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(5)
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
        
        // FPS 实时显示
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
        
        let hintLabel = UILabel()
        hintLabel.text = "观察上方红色方块\n如果不卡顿，它会一直流畅旋转\n如果卡顿，它会停止不动"
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .gray
        view.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(fpsLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .center
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(40.0)
            make.width.equalToSuperview()
        }
        
        // 场景 1: 主线程 JSON 解析 (常见错误)
        let btn1 = createButton(title: "1. 主线程大量 JSON 解析", action: #selector(runHeavyJSONParsing))
        stackView.addArrangedSubview(btn1)
        
        // 场景 2: 复杂计算 (算法耗时)
        let btn2 = createButton(title: "2. 斐波那契数列 (递归)", action: #selector(runFibonacci))
        stackView.addArrangedSubview(btn2)
        
        // 场景 3: 频繁 IO 操作
        let btn3 = createButton(title: "3. 主线程读写文件", action: #selector(runFileIO))
        stackView.addArrangedSubview(btn3)
        
        // 场景 4: DateFormatter 滥用
        let btn4 = createButton(title: "4. DateFormatter 频繁创建", action: #selector(runDateFormatter))
        stackView.addArrangedSubview(btn4)
        
        // 场景 5: 图片处理 (滤镜/重绘)
        let btn5 = createButton(title: "5. 主线程图片处理", action: #selector(runImageProcessing))
        stackView.addArrangedSubview(btn5)
        
        // 场景 6: 布局震荡 (Layout Thrashing)
        let btn6 = createButton(title: "6. 强制大量 Layout", action: #selector(runLayoutThrashing))
        stackView.addArrangedSubview(btn6)
        
        // 场景 7: 主线程休眠 (Sleep) - 低 CPU 卡顿
        let btn7 = createButton(title: "7. 主线程 Sleep 5秒 (低 CPU)", action: #selector(runSleep))
        stackView.addArrangedSubview(btn7)
        
        // 场景 8: 忙等待 (Busy Wait) - 高 CPU 卡顿
        let btn8 = createButton(title: "8. 忙等待 5秒 (高 CPU)", action: #selector(runBusyWait))
        stackView.addArrangedSubview(btn8)
    }
    
    private func startAnimation() {
        // 使用 CADisplayLink 来驱动动画
        // 相比 CABasicAnimation (CoreAnimation)，DisplayLink 严格依赖主线程 RunLoop
        // 一旦主线程被阻塞，DisplayLink 回调停止，动画就会立刻卡死，这是检测主线程卡顿最准确的方法
        displayLink = CADisplayLink(target: self, selector: #selector(tick(link:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func tick(link: CADisplayLink) {
        // 1. 旋转动画 (视觉检测)
        indicatorView.transform = indicatorView.transform.rotated(by: 0.1)
        
        // 2. FPS 计算 (数值检测)
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        
        frameCount += 1
        let delta = link.timestamp - lastTime
        if delta >= 1.0 {
            let fps = Double(frameCount) / delta
            fpsLabel.text = String(format: "FPS: %.0f", fps)
            
            // 颜色警告
            if fps < 50 {
                fpsLabel.textColor = .systemRed
            } else {
                fpsLabel.textColor = .systemGreen
            }
            
            lastTime = link.timestamp
            frameCount = 0
        }
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    // MARK: - Heavy Tasks
    
    @objc private func runHeavyJSONParsing() {
        print("开始 JSON 解析任务...")
        // 模拟一个超大的 JSON 数据
        // 增加数据量以确保 Simulator 上也能卡顿
        let count = 200000 
        var jsonString = "["
        for i in 0..<count {
            jsonString += "{\"id\":\(i), \"name\":\"User \(i)\", \"desc\":\"This is a long description to simulate heavy parsing task.\"},"
        }
        jsonString = String(jsonString.dropLast()) + "]"
        
        guard let data = jsonString.data(using: .utf8) else { return }
        
        // ❌ 错误做法：在主线程进行大量解析
        let start = CACurrentMediaTime()
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            let end = CACurrentMediaTime()
            print("JSON 解析完成，耗时: \(end - start)秒")
        } catch {
            print(error)
        }
    }
    
    @objc private func runFibonacci() {
        print("开始斐波那契计算...")
        // ❌ 递归计算非常消耗 CPU
        // 增加到 42，确保在 M1/M2 上也能卡 1-2 秒
        let start = CACurrentMediaTime()
        _ = fibonacci(42) 
        let end = CACurrentMediaTime()
        print("计算完成，耗时: \(end - start)秒")
    }
    
    private func fibonacci(_ n: Int) -> Int {
        if n <= 1 { return n }
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
    
    @objc private func runFileIO() {
        print("开始文件 IO...")
        let fileName = "test_io.txt"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        // 增加写入量
        let largeString = String(repeating: "Heavy IO Operation ", count: 2000000)
        
        let start = CACurrentMediaTime()
        // ❌ 主线程写入
        try? largeString.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // ❌ 主线程读取
        _ = try? String(contentsOf: fileURL)
        let end = CACurrentMediaTime()
        print("IO 完成，耗时: \(end - start)秒")
    }
    
    @objc private func runDateFormatter() {
        print("开始 DateFormatter 测试...")
        let start = CACurrentMediaTime()
        
        // ❌ DateFormatter 创建非常耗时，不应在循环中创建
        // 增加循环次数
        for _ in 0..<20000 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            _ = formatter.string(from: Date())
        }
        
        let end = CACurrentMediaTime()
        print("DateFormatter 完成，耗时: \(end - start)秒")
    }
    
    @objc private func runImageProcessing() {
        print("开始图片处理...")
        guard let image = UIImage(systemName: "photo.artframe") else { return }
        
        let start = CACurrentMediaTime()
        
        // ❌ 主线程进行高斯模糊或重绘
        for _ in 0..<100 {
            let context = CIContext(options: nil)
            if let currentFilter = CIFilter(name: "CIGaussianBlur") {
                let beginImage = CIImage(image: image)
                currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
                currentFilter.setValue(10, forKey: kCIInputRadiusKey)
                
                if let output = currentFilter.outputImage,
                   let cgimg = context.createCGImage(output, from: output.extent) {
                    _ = UIImage(cgImage: cgimg)
                }
            }
        }
        
        let end = CACurrentMediaTime()
        print("图片处理完成，耗时: \(end - start)秒")
    }
    
    @objc private func runLayoutThrashing() {
        print("开始 Layout Thrashing...")
        let start = CACurrentMediaTime()
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        // ❌ 频繁调用 layoutIfNeeded 会导致 CPU 在 Layout 阶段满载
        for i in 0..<2000 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            container.addSubview(view)
            view.frame.origin.x = CGFloat(i % 300)
            container.layoutIfNeeded() // 强制立即布局
        }
        
        let end = CACurrentMediaTime()
        print("Layout Thrashing 完成，耗时: \(end - start)秒")
    }
    
    @objc private func runSleep() {
        print("开始主线程休眠 5秒...")
        let start = CACurrentMediaTime()
        
        // ❌ 这种卡顿 CPU 占用率极低（几乎为0），但在 Time Profiler 里 Weight 很高（5秒）
        // 模拟：同步等待锁、同步网络请求
        Thread.sleep(forTimeInterval: 5.0)
        
        let end = CACurrentMediaTime()
        print("休眠结束，耗时: \(end - start)秒")
    }
    
    @objc private func runBusyWait() {
        print("开始忙等待 5秒...")
        let start = CACurrentMediaTime()
        
        // ❌ 这种卡顿 CPU 占用率满载（100%），Weight 也很高
        // 模拟：死循环、极度密集的逻辑判断
        while (CACurrentMediaTime() - start < 5.0) {
            // 空转，什么都不做，纯烧 CPU
        }
        
        let end = CACurrentMediaTime()
        print("忙等待结束，耗时: \(end - start)秒")
    }
}
