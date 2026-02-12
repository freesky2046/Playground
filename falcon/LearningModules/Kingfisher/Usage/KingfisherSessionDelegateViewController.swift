import UIKit

/// 演示 URLSessionDelegate 使用的视图控制器
/// 模拟 Kingfisher 中 SessionDelegate 的核心逻辑
class KingfisherSessionDelegateViewController: UIViewController, URLSessionDataDelegate {
    
    // MARK: - UI 元素
     var imageView: UIImageView = UIImageView()
     var progressView: UIProgressView = UIProgressView()
     var statusLabel: UILabel = UILabel()
    
    // MARK: - 网络相关属性
    
    /// URLSession 实例
    private var session: URLSession!
    
    /// 存储下载任务的回调和数据
    /// 键：URLSessionDataTask 实例
    /// 值：(累积数据, 进度回调, 完成回调)
    private var taskMap: [URLSessionDataTask: (Data, ((Double) -> Void)?, ((UIImage?, Error?) -> Void))] = [:]
    
    /// 线程安全队列（用于操作 taskMap）
    private let taskMapQueue = DispatchQueue(label: "com.example.KingfisherSessionDelegateViewController.TaskMapQueue")
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
        setupUI()
      
    }
    
    /// 设置 UI 初始状态
    private func setupUI() {
        view.backgroundColor = .white
        progressView.frame = CGRectMake(UIScreen.main.bounds.size.width * 0.5, UIScreen.main.bounds.size.height * 0.5, 10, 10)
        progressView.progress = 0.0
        progressView.isHidden = false
        statusLabel.frame = CGRectMake(UIScreen.main.bounds.size.width * 0.5, UIScreen.main.bounds.size.height * 0.5, 10, 10)
        statusLabel.text = "准备下载"
        imageView.frame = CGRectMake((UIScreen.main.bounds.size.width - 300) * 0.5, (UIScreen.main.bounds.size.height - 400) * 0.5, 300, 400)
        imageView.image = nil
        
        view.addSubview(progressView)
        view.addSubview(statusLabel)
        view.addSubview(imageView)
        
        startDownloadTapped()
    }
    
    /// 初始化 URLSession
    private func setupSession() {
        // 配置会话
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15 // 超时时间 15 秒
        
        // 创建会话并设置代理
        // 注意：delegateQueue 为 nil 时，代理回调会在后台线程执行
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - 下载方法
    
    /// 开始下载图片
    /// - Parameter url: 图片 URL
    func startDownload(with url: URL) {
        statusLabel.text = "开始下载"
        
        // 创建数据任务
        let task = session.dataTask(with: url)
        
        // 定义进度回调
        let progressBlock: ((Double) -> Void) = { [weak self] progress in
            DispatchQueue.main.async {
                self?.progressView.progress = Float(progress)
                self?.statusLabel.text = "下载中: \(Int(progress * 100))%"
            }
        }
        
        // 定义完成回调
        let completionBlock: ((UIImage?, Error?) -> Void) = { [weak self] image, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.statusLabel.text = "下载失败: \(error.localizedDescription)"
                    return
                }
                
                self?.imageView.image = image
                self?.statusLabel.text = "下载完成"
                self?.progressView.isHidden = true
            }
        }
        
        // 存储任务信息
        taskMapQueue.sync {
            taskMap[task] = (Data(), progressBlock, completionBlock)
        }
        
        // 开始任务
        task.resume()
    }
    
    // MARK: - URLSessionDataDelegate 代理方法
    
    /// 接收服务器响应头
    /// - Parameters:
    ///   - session: URLSession 实例
    ///   - dataTask: 当前数据任务
    ///   - response: 服务器响应
    ///   - completionHandler: 完成回调（决定是否继续下载）
    /// 
    /// 对应 Kingfisher 中 SessionDelegate 的 urlSession(_:dataTask:didReceive:completionHandler:) 方法
    /// 用于确认是否继续下载数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // 允许继续下载
        // 在 Kingfisher 中，这里可能会进行响应验证（如状态码检查）
        
        print("1️⃣:接收响应头")
        completionHandler(.allow)
    }
    
    /// 接收数据
    /// - Parameters:
    ///   - session: URLSession 实例
    ///   - dataTask: 当前数据任务
    ///   - data: 新接收到的数据块
    /// 
    /// 对应 Kingfisher 中 SessionDelegate 的 urlSession(_:dataTask:didReceive:) 方法
    /// 用于累积下载数据并更新进度
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("2️⃣:接受数据")
        taskMapQueue.sync {
            // 安全获取任务信息
            guard var (existingData, progressBlock, completionBlock) = taskMap[dataTask] else { return }
            
            // 累积数据
            existingData.append(data)
            
            // 更新任务信息
            taskMap[dataTask] = (existingData, progressBlock, completionBlock)
            
            // 计算进度
            if let response = dataTask.response as? HTTPURLResponse, 
               let expectedLength = response.expectedContentLength as Int64? {
                let progress = Double(existingData.count) / Double(expectedLength)
                // 调用进度回调
                progressBlock?(progress)
            }
        }
    }
    
    /// 任务完成
    /// - Parameters:
    ///   - session: URLSession 实例
    ///   - task: 完成的任务
    ///   - error: 错误信息（如果有）
    /// 
    /// 对应 Kingfisher 中 SessionDelegate 的 urlSession(_:task:didCompleteWithError:) 方法
    /// 用于处理下载完成后的逻辑（成功或失败）
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("3️⃣:任务完成")
        taskMapQueue.sync {
            // 安全获取并移除任务信息
            guard let dataTask = task as? URLSessionDataTask, 
                  let (data, _, completionBlock) = taskMap.removeValue(forKey: dataTask) else { return }
            
            // 处理结果
            if let error = error {
                // 调用完成回调（失败）
                completionBlock(nil, error)
                return
            }
            
            // 尝试解码图片
            if let image = UIImage(data: data) {
                // 调用完成回调（成功）
                completionBlock(image, nil)
            } else {
                // 图片解码失败
                let decodeError = NSError(domain: "DownloadError", 
                                         code: -1, 
                                         userInfo: [NSLocalizedDescriptionKey: "图片解码失败"])
                completionBlock(nil, decodeError)
            }
        }
    }
    
    /// 处理认证挑战
    /// - Parameters:
    ///   - session: URLSession 实例
    ///   - task: 当前任务
    ///   - challenge: 认证挑战
    ///   - completionHandler: 完成回调
    /// 
    /// 对应 Kingfisher 中 SessionDelegate 的 urlSession(_:task:didReceive:completionHandler:) 方法
    /// 用于处理网络认证（如 HTTPS 证书验证）
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, challenge.proposedCredential)
//        completionHandler(.performDefaultHandling, nil)
    }
    
    // MARK: - 操作方法
    
    /// 开始下载示例图片
    func startDownloadTapped() {
        if let url = URL(string: "https://picsum.photos/800/600") {
            startDownload(with: url)
        }
    }
    
    /// 取消当前下载
    func cancelDownloadTapped(_ sender: UIButton) {
        // 取消所有任务
        session.invalidateAndCancel()
        // 清理任务映射
        taskMapQueue.sync {
            taskMap.removeAll()
        }
        // 重置 UI
        statusLabel.text = "下载已取消"
        progressView.progress = 0.0
        // 重新创建会话
        setupSession()
    }
}
