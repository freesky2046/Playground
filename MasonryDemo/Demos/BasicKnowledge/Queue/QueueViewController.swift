//
//  QueueViewController.swift
//  MasonryDemo
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
    
    var dataList: [ItemModel] = [
        ItemModel(title: "多线程同步 + 并行队列", subtitle: "不开新线程,在各自提交线程并行执行", icon: "0.circle.fill", actionKey: "0"),
        ItemModel(title: "多线程同步 + 串行队列", subtitle: "执行顺序有保障,按照提交顺序执行", icon: "1.circle.fill", actionKey: "1"),
        ItemModel(title: "多线程异步 + 并行队列", subtitle: "开多新线程,任务在不同线程执行", icon: "2.circle.fill", actionKey: "2"),
        ItemModel(title: "多线程异步 + 串行队列", subtitle: "串行队列保证顺序，通常在一个新线程", icon: "3.circle.fill", actionKey: "3"),
        
        ItemModel(title: "单线程同步 + 并行队列", subtitle: "和不加队列效果一样,不开线程", icon: "4.circle.fill", actionKey: "4"),
        ItemModel(title: "单线程同步 + 串行队列", subtitle: "和不加队列效果一样,不开线程", icon: "5.circle.fill", actionKey: "5"),
        ItemModel(title: "单线程异步 + 并行队列", subtitle: "开多个线程,并行执行", icon: "6.circle.fill", actionKey: "6"),
        ItemModel(title: "单线程同步 + 串行队列", subtitle: "和不加队列效果一样,不开线程", icon: "7.circle.fill", actionKey: "7"),
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
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

    func codition8() {
        let onlySuperLock = OnlySuperLockViewController()
        navigationController?.pushViewController(onlySuperLock, animated: true)
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
        return 88.0 // 卡片高度
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataList[indexPath.row]
        
        switch model.actionKey {
        case "0":
            self.codition0()
        case "1":
            self.codition1()
        case "2":
            self.codition2()
        case "3":
            self.codition3()
        case "8":
            self.codition8()
        default:
            print("Selected: \(model.title)")
        }
    }
}

extension QueueViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
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
