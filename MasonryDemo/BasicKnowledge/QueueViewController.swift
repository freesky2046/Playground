//
//  QueueViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/4.
//

import UIKit
import SnapKit

class QueueViewController: UIViewController {
    var dataList: [String] = [
        "0.多线程同步提交+并行队列:不开新线程,在各自提交线程并行执行",
        "1.多线程同步提交+串行队列:不开新线程,在各自提交线程执行,但是执行顺序有保障,按照提交顺序执行",
        "2.多线程异步提交+并行队列:开多新线程,队列上的任务执行线程和提交线程不一样,且任务不同线程",
        "3.多线程异步提交+串行队列:串行队列保证顺序，但线程可能变化(通常是一个线程)",
        
        "4.单线程同步提交多个任务+并行队列:和不加队列的执行效果一样,不开线程",
        "5.单线程同步提交多个任务+串行队列:和不加队列的执行效果一样,不开线程",
        "6.单线程异步提交多个任务+并行队列:开多个线程,并行执行",
        "7.单线程同步提交多个任务+串行队列:和不加队列的执行效果一样,不开线程",
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        return tableView
    }()

    let serial = DispatchQueue(label: "com.serial.queue")
    let corruent = DispatchQueue(label: "com.corruent.queue", attributes: .concurrent)
    
    let serial2 = DispatchQueue(label: "com.serial2.queue")
    let corruent2 = DispatchQueue(label: "com.corruent2.queue", attributes: .concurrent)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(100.0)
        }


    }
    
    
    // 测试多个线程同步+并行
    // 不开新线程,在各自提交线程并行执行
    func codition0() {
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
        let thread4 = Thread(target: self, selector: #selector(asyncCommitCorruent), object: nil)
        thread4.start()
        let thread5 = Thread(target: self, selector: #selector(asyncCommitCorruent), object: nil)
        thread5.start()
        let thread6 = Thread(target: self, selector: #selector(asyncCommitCorruent), object: nil)
        thread6.start()
    }
    
    // 测试多个线程异步+并行
    func codition3() {
        let thread4 = Thread(target: self, selector: #selector(asyncCommitSerial), object: nil)
        thread4.start()
        let thread5 = Thread(target: self, selector: #selector(asyncCommitSerial), object: nil)
        thread5.start()
        let thread6 = Thread(target: self, selector: #selector(asyncCommitSerial), object: nil)
        thread6.start()
    }
    
    
    // 同步并行
    @objc func syncCommitCorruent() {
//        print("syncCommitCorruent开始:\(Thread.current)")
        corruent.sync {
            print("syncCommitCorruent开始:\(Thread.current)")
            for i in 1...100000 {
                sqrt(Double(i))
            }
            print("syncCommitCorruent结束:\(Thread.current)")
        }
    }
    
    // 同步串行
    @objc func syncCommitSerial() {
        serial.sync {
            print("syncCommitSerial开始:\(Thread.current)")
            for i in 1...100000 {
                sqrt(Double(i))
            }
            print("syncCommitSerial结束:\(Thread.current)")
        }
    }
    
    
    // 异步并行
    @objc func asyncCommitCorruent() {
        print("提交所在线程开始:\(Thread.current)")
        corruent2.async {
            print("asyncCommitCorruent开始:\(Thread.current)")
            for i in 1...100000 {
                sqrt(Double(i))
            }
            print("asyncCommitCorruent结束:\(Thread.current)")
        }
    }

    // 异步串行
    @objc func asyncCommitSerial() {
        print("提交所在线程开始:\(Thread.current)")
        serial2.async {
            print("asyncCommitCorruent开始:\(Thread.current)")
            for i in 1...100000 {
                sqrt(Double(i))
            }
            print("asyncCommitCorruent结束:\(Thread.current)")
        }
    }
    
    

}

extension QueueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = dataList[indexPath.row].first
        
        switch title {
        case "0":
            self.codition0()
        case "1":
            self.codition1()
        case "2":
            self.codition2()
        case "3":
            self.codition3()
        default:
            break
        }
    }
}

extension QueueViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = dataList[indexPath.row]
        return cell
    }
}
