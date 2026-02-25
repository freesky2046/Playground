//
//  RunLoopDemoViewController.swift
//  falcon
//
//  Created by falcon on 2026/02/13.
//

import UIKit
import SnapKit

class RunLoopDemoViewController: UIViewController {
    
    private let textView = UITextView()
    private var observer: CFRunLoopObserver?
    private var isObserving = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RunLoop Insights"
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // Buttons
        let startBtn = createButton(title: "开始观察 RunLoop (Log)", action: #selector(startObserving))
        let stopBtn = createButton(title: "停止观察", action: #selector(stopObserving))
        let taskBtn = createButton(title: "模拟耗时任务 (卡顿)", action: #selector(runHeavyTask))
        let timerBtn = createButton(title: "调度 Timer (2s后唤醒)", action: #selector(scheduleTimer))
        let performBtn = createButton(title: "后台 -> performSelector (Source0唤醒)", action: #selector(runPerformSelector))
        let networkBtn = createButton(title: "模拟网络回调 (Source0/1唤醒)", action: #selector(runNetworkRequest))
        
        stackView.addArrangedSubview(startBtn)
        stackView.addArrangedSubview(stopBtn)
        stackView.addArrangedSubview(taskBtn)
        stackView.addArrangedSubview(timerBtn)
        stackView.addArrangedSubview(performBtn)
        stackView.addArrangedSubview(networkBtn)
        
        // Log View
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textView.isEditable = false
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview().inset(20)
        }
        
        // Initial Tip
        log("点击 '开始观察' 查看 RunLoop 状态流转")
        log("RunLoop 状态说明：\n1. Entry: 进入循环\n2. BeforeTimers: 即将处理 Timer\n3. BeforeSources: 即将处理 Source\n4. BeforeWaiting: 即将休眠 (关键)\n5. AfterWaiting: 刚被唤醒\n6. Exit: 退出循环")
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    // MARK: - RunLoop Logic
    
    @objc private func startObserving() {
        guard !isObserving else { return }
        isObserving = true
        log("\n=== 开始观察 Main RunLoop ===")
        
        // 创建 Observer
        // activities: 监听所有状态
        // repeats: true 持续监听
        observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0) { [weak self] observer, activity in
            guard let self = self else { return }
            let state = self.activityToString(activity)
            
            // 为了避免 Log 刷屏太快导致自身卡顿，只在特定状态或采样打印
            // 这里为了演示，直接打印，实际可能会非常快
            print("RunLoop: \(state)")
            
        }
        
        if let observer = observer {
            CFRunLoopAddObserver(CFRunLoopGetMain(), observer, .commonModes)
        }
    }
    
    @objc private func stopObserving() {
        guard isObserving, let observer = observer else { return }
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, .commonModes)
        self.observer = nil
        isObserving = false
        log("=== 停止观察 ===")
    }
    
    @objc private func runHeavyTask() {
        log("\n>>> 开始执行 2秒 耗时任务 (阻塞主线程)...")
        // 模拟卡顿，此时 RunLoop 无法流转，一直停留在 AfterWaiting 或处理 Source 的状态
        let start = Date()
        while Date().timeIntervalSince(start) < 2.0 {
            // Busy waiting
        }
        log("<<< 耗时任务结束，RunLoop 继续流转")
    }
    
    @objc private func scheduleTimer() {
        log("\n>>> Timer 已调度，将在 2秒后 触发...")
//        // Timer 加入 RunLoop 后，RunLoop 会根据下一次 Timer 的时间设置超时唤醒
//        // 所以即使没有触摸事件，RunLoop 也会在 2秒后自动醒来
//        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
//            self?.log("⏰ Timer 触发！RunLoop 被 Timer 机制(超时)叫醒")
//        }
    }
    
    @objc private func runPerformSelector() {
        log("\n>>> 启动后台线程，2秒后调用 performSelector...")
        DispatchQueue.global().async { [weak self] in
            sleep(2)
            // performSelector:onThread: 内部会自动调用 CFRunLoopWakeUp
            // 所以即使 RunLoop 正在休眠，也会被强制唤醒来处理这个 Source 0
            self?.performSelector(onMainThread: #selector(self?.handlePerformSelector), with: nil, waitUntilDone: false)
        }
    }
    
    @objc private func handlePerformSelector() {
        log("📨 performSelector 执行！RunLoop 被 Source0 (WakeUp) 唤醒")
    }
    
    @objc private func runNetworkRequest() {
        log("\n>>> 模拟网络请求发送，等待 2秒...")
        DispatchQueue.global().async { [weak self] in
            sleep(2)
            // 模拟网络库在后台线程收到数据后，dispatch_async 到主线程
            // libdispatch 会通过 Port (Source 1) 唤醒主线程 RunLoop
            DispatchQueue.main.async {
                self?.log("📡 网络请求回调！RunLoop 被 GCD (Source1) 唤醒")
            }
        }
    }
    
    private func activityToString(_ activity: CFRunLoopActivity) -> String {
        switch activity {
        case .entry: return "Entry (进入)"                    //0. 首次进入
        case .afterWaiting: return "AfterWaiting (被唤醒 ⏰)" // 1.刚被叫醒（开始干活）：
        case .beforeTimers: return "BeforeTimers (处理Timer)" // 2.处理timer
        case .beforeSources: return "BeforeSources (处理Source)" // 3.包括source0和source1
        case .beforeWaiting: return "BeforeWaiting (准备休眠 💤)" // 4.BeforeWaiting 马上进入休眠,这个时候会把标记label.text = "22"的脏数据,画到屏幕上
        case .exit: return "Exit (退出)" // 5.释放
        default: return "Unknown"
        }
    }
    
    private func log(_ text: String) {
        // 追加文本并滚动到底部
        let current = textView.text ?? ""
        textView.text = current + "\n" + text
        let bottom = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(bottom)
    }
}
