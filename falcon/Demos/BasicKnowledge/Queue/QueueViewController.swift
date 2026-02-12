//
//  QueueViewController.swift
//  falcon
//
//  Created by 周明 on 2026/2/4.
//

import UIKit
import SnapKit

class QueueViewController: UIViewController {
    
    // 数据模型结构体
    struct ItemModel {
        let title: String
        let subtitle: String
        let icon: String
        let actionKey: String
    }
    
    // 日志显示视图
    lazy var logTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .black
        textView.textColor = .green
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = false
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.text = "👉 点击上方列表项开始测试...\n"
        return textView
    }()
    
    var dataList: [ItemModel] = [
        ItemModel(title: "多线程同步 + 并行队列", subtitle: "不开新线程,在各自提交线程并行执行", icon: "0.circle.fill", actionKey: "0"),
        ItemModel(title: "多线程同步 + 串行队列", subtitle: "执行顺序有保障,按照提交顺序执行", icon: "1.circle.fill", actionKey: "1"),
        ItemModel(title: "多线程异步 + 并行队列", subtitle: "开多新线程,任务在不同线程执行", icon: "2.circle.fill", actionKey: "2"),
        ItemModel(title: "多线程异步 + 串行队列", subtitle: "串行队列保证顺序，通常在一个新线程", icon: "3.circle.fill", actionKey: "3"),
        
        ItemModel(title: "单线程同步 + 并行队列", subtitle: "不开线程, 串行执行", icon: "4.circle.fill", actionKey: "4"),
        ItemModel(title: "单线程同步 + 串行队列", subtitle: "不开线程, 串行执行", icon: "5.circle.fill", actionKey: "5"),
        ItemModel(title: "单线程异步 + 并行队列", subtitle: "开启新线程, 并行执行", icon: "6.circle.fill", actionKey: "6"),
        ItemModel(title: "单线程异步 + 串行队列", subtitle: "开启新线程, 串行执行", icon: "7.circle.fill", actionKey: "7"),
        ItemModel(title: "锁测试", subtitle: "仅父有锁,子无锁", icon: "lock.open.fill", actionKey: "8")
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = DSColor.backgroundPrimary
        tableView.contentInset = UIEdgeInsets(top: DSSpacing.m, left: 0, bottom: DSSpacing.m, right: 0)
        tableView.register(DSCardListCell.self, forCellReuseIdentifier: "DSCardListCell")
        return tableView
    }()

    let serial = DispatchQueue(label: "com.serial.queue")
    let corruent = DispatchQueue(label: "com.corruent.queue", attributes: .concurrent)
    
    let serial2 = DispatchQueue(label: "com.serial2.queue")
    let corruent2 = DispatchQueue(label: "com.corruent2.queue", attributes: .concurrent)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GCD Queue"
        view.backgroundColor = DSColor.backgroundPrimary
        
        view.addSubview(tableView)
        view.addSubview(logTextView)
        
        // 分配布局：上面是列表，下面是日志控制台
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        logTextView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func appendLog(_ text: String) {
        // 在调用时立即获取时间，保证时间戳准确反映事件发生时刻，而不是UI刷新时刻
        let now = Date()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss.SSS"
            let timeString = dateFormatter.string(from: now)
            
            let logString = "[\(timeString)] \(text)\n"
            self.logTextView.text.append(logString)
            
            // 滚动到底部
            let bottom = NSMakeRange(self.logTextView.text.count - 1, 1)
            self.logTextView.scrollRangeToVisible(bottom)
        }
    }

    // 测试多个线程同步+并行
    // 不开新线程,在各自提交线程并行执行
    func codition0() {
        appendLog("\n--- 多线程同步 + 并行队列 ---")
        let thread1 = Thread(target: self, selector: #selector(syncCommitCorruent), object: nil)
        thread1.start()
        let thread2 = Thread(target: self, selector: #selector(syncCommitCorruent), object: nil)
        thread2.start()
        let thread3 = Thread(target: self, selector: #selector(syncCommitCorruent), object: nil)
        thread3.start()
    }

    // 测试多个线程同步+串行
    // 不开新线程,在各自提交线程执行,但是执行顺序有保障,按照提交顺序执行
    func codition1() {
        appendLog("\n--- 多线程同步 + 串行队列 ---")
        let thread4 = Thread(target: self, selector: #selector(syncCommitSerial), object: nil)
        thread4.start()
        let thread5 = Thread(target: self, selector: #selector(syncCommitSerial), object: nil)
        thread5.start()
        let thread6 = Thread(target: self, selector: #selector(syncCommitSerial), object: nil)
        thread6.start()
    }

    // 测试多个线程异步+并行
    //
    func codition2() {
        appendLog("\n--- 多线程异步 + 并行队列 ---")
        let thread4 = Thread(target: self, selector: #selector(asyncCommitCorruent), object: nil)
        thread4.start()
        let thread5 = Thread(target: self, selector: #selector(asyncCommitCorruent), object: nil)
        thread5.start()
        let thread6 = Thread(target: self, selector: #selector(asyncCommitCorruent), object: nil)
        thread6.start()
    }

    // 测试多个线程异步+串行
    func codition3() {
        appendLog("\n--- 多线程异步 + 串行队列 ---")
        let thread4 = Thread(target: self, selector: #selector(asyncCommitSerial), object: nil)
        thread4.start()
        let thread5 = Thread(target: self, selector: #selector(asyncCommitSerial), object: nil)
        thread5.start()
        let thread6 = Thread(target: self, selector: #selector(asyncCommitSerial), object: nil)
        thread6.start()
    }

    // 单线程同步 + 并行队列
    func codition4() {
        appendLog("\n--- 单线程同步 + 并行队列 ---")
        // 注意：这里如果在主线程调用，界面会卡顿，直到任务结束
        // 为了演示日志，我们用一个后台线程包裹一下，模拟单线程环境
        DispatchQueue.global().async {
            self.syncCommitCorruent()
            self.syncCommitCorruent()
            self.syncCommitCorruent()
        }
    }

    // 单线程同步 + 串行队列
    func codition5() {
        appendLog("\n--- 单线程同步 + 串行队列 ---")
        DispatchQueue.global().async {
            self.syncCommitSerial()
            self.syncCommitSerial()
            self.syncCommitSerial()
        }
    }
    
    // 单线程异步 + 并行队列
    func codition6() {
        appendLog("\n--- 单线程异步 + 并行队列 ---")
        asyncCommitCorruent()
        asyncCommitCorruent()
        asyncCommitCorruent()
    }
    
    // 单线程异步 + 串行队列
    func codition7() {
        appendLog("\n--- 单线程异步 + 串行队列 ---")
        asyncCommitSerial()
        asyncCommitSerial()
        asyncCommitSerial()
    }
    
    func codition8() {
        let onlySuperLock = OnlySuperLockViewController()
        navigationController?.pushViewController(onlySuperLock, animated: true)
    }
    
    // 同步并行
    @objc func syncCommitCorruent() {
        let currentThread = Thread.current
        
        corruent.sync {
            appendLog("同步并行开始: \(currentThread)")
            for i in 1...100000 {
                sqrt(Double(i))
            }
            appendLog("同步并行结束: \(currentThread)")
        }
    }
    
    // 同步串行
    @objc func syncCommitSerial() {
        let currentThread = Thread.current
        serial.sync {
            appendLog("同步串行开始: \(currentThread)")
            for i in 1...100000 {
                sqrt(Double(i))
            }
            appendLog("同步串行结束: \(currentThread)")
        }
    }
    
    
    // 异步并行
    @objc func asyncCommitCorruent() {
        let submitThread = Thread.current
        appendLog("提交异步并行任务: \(submitThread)")
        corruent2.async {
            self.appendLog("异步并行执行中: \(Thread.current)")
            for i in 1...100000 {
                sqrt(Double(i))
            }
        }
    }
    
    // 异步串行
    @objc func asyncCommitSerial() {
        let submitThread = Thread.current
        appendLog("提交异步串行任务: \(submitThread)")
        serial2.async {
            self.appendLog("异步串行执行中: \(Thread.current)")
            for i in 1...100000 {
                sqrt(Double(i))
            }
        }
    }
    
    

}

extension QueueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0 // 卡片高度
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataList[indexPath.row]
        
        // 清空之前的日志，方便观察本次结果
        logTextView.text = ""
        appendLog("选中: \(model.title)")
        
        switch model.actionKey {
        case "0":
            self.codition0()
        case "1":
            self.codition1()
        case "2":
            self.codition2()
        case "3":
            self.codition3()
        case "4":
            self.codition4()
        case "5":
            self.codition5()
        case "6":
            self.codition6()
        case "7":
            self.codition7()
        case "8":
            self.codition8()
        default:
            print("Selected: \(model.title)")
        }
    }
}

extension QueueViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DSCardListCell", for: indexPath) as? DSCardListCell else {
            return UITableViewCell()
        }
        let model = dataList[indexPath.row]
        cell.configure(title: model.title, subtitle: model.subtitle, iconName: model.icon)
        return cell
    }
}
