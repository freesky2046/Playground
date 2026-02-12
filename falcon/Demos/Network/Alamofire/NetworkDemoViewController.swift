//
//  NetworkDemoViewController.swift
//  falcon
//
//  Created by falcon on 2026/2/12.
//

import UIKit
import SnapKit
import Alamofire

class NetworkDemoViewController: UIViewController, RouteCompatible {
    
    // MARK: - RouteCompatible
    // 即使这里不需要接收参数，为了遵守协议也需要实现（或者协议有默认实现）
    // 这里我们不做任何处理
    
    // MARK: - Properties
    private let tableView = UITableView()
    private var posts: [DemoGistModel] = []
    
    // Cache instance
    private lazy var cache: SimpleCache = {
        return SimpleCache(name: "NetworkDemoCache")
    }()
    private let cacheKey = "gist_data"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Alamofire + SimpleCache"
        view.backgroundColor = DSColor.backgroundPrimary
        
        // Add Clear Cache Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear Cache",
            style: .plain,
            target: self,
            action: #selector(clearCache)
        )
        
        // Setup TableView
        tableView.backgroundColor = DSColor.backgroundPrimary
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DSCardListCell.self, forCellReuseIdentifier: "DSCardListCell")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func clearCache() {
        cache.remove(for: cacheKey)
        posts = []
        tableView.reloadData()
        DSToast.show(message: "Cache Cleared", in: view)
    }
    
    // MARK: - Data Fetching
    private func loadData() {
        // 1. Try to load from Cache first
        cache.object(for: cacheKey, as: DemoBaseResponse<DemoGistModel>.self) { [weak self] cachedResponse in
            guard let self = self else { return }
            
            if let data = cachedResponse?.data {
                print("✅ Hit Cache")
                self.posts = [data]
                self.tableView.reloadData()
                DSToast.show(message: "Loaded from Cache", in: self.view)
            } else {
                print("❌ Cache Miss")
            }
            
            // 2. Fetch from Network (Always fetch to update)
            self.fetchFromNetwork(isSilently: !self.posts.isEmpty)
        }
    }
    
    private func fetchFromNetwork(isSilently: Bool) {
        let loadingView = DSLoadingView()
        
        if !isSilently {
            view.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            loadingView.startAnimating()
        }
        
        // Use our encapsulated NetworkManager
        // Note: The URL below returns a Python script, not JSON. Ideally, this should be a valid JSON endpoint.
        let url = "https://gist.githubusercontent.com/freesky2046/c04f3621c4fd390aecd65cf76a5b002a/raw/82e39581afe12551ae1de79d40946d77cde33080/gistfile1.txt"
        
        NetworkManager.shared.sendCodable(url, method: .get, decodeType: DemoBaseResponse<DemoGistModel>.self) { [weak self] result in
            guard let self = self else { return }
            
            loadingView.stopAnimating()
            loadingView.removeFromSuperview()
            
            switch result {
            case .success(let response):
                if let data = response.data {
                    // Update UI
                    self.posts = [data]
                    self.tableView.reloadData()
                    
                    if !isSilently {
                         DSToast.show(message: "Loaded from Network", in: self.view)
                    }
                    
                    // 3. Save to Cache
                    self.cache.setObject(object: response, for: self.cacheKey)
                    print("💾 Saved to Cache")
                } else {
                    if !isSilently { self.showError("No data received") }
                }
                
            case .failure(let error):
                if !isSilently { self.showError(error.localizedDescription) }
            }
        }
    }
    
    private func showError(_ message: String) {
        DSToast.show(message: message, in: view)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension NetworkDemoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DSCardListCell", for: indexPath) as? DSCardListCell else {
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]
        cell.configure(
            title: post.name ?? "Unknown",
            subtitle: "Age: \(post.age ?? 0)",
            iconName: "person.circle.fill"
        )
        cell.elevation = .low
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let post = posts[indexPath.row]
        let name = post.name ?? "Unknown"
        let age = "\(post.age ?? 0)"
        
        // 演示使用 SimpleRouter 跳转到详情页
        // 构建 URL: md://gistDetail?name=xxx&age=xxx
        let urlString = "md://gistDetail?name=\(name)&age=\(age)"
        
        // 注意：实际项目中应该对参数进行 URL 编码
        if let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            SimpleRouter.shared.to(url: encodedUrl)
        }
    }
}

// MARK: - Models for Demo
// Based on the Gist response structure
struct DemoBaseResponse<T: Codable>: Codable {
    let code: Int?
    let message: String?
    let data: T?
}

struct DemoGistModel: Codable {
    var name: String?
    var age: Int?
}
