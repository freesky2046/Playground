//
//  KingfisherSessionDelegate.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import Foundation
import UIKit

class KingfisherSessionDelegate: NSObject {
    /// 存储下载任务的回调和数据
    /// 键：Task Identifier (Int)
    private var tasks: [Int: KingfisherSessionDataTask] = [:]

    /// 线程安全队列（用于操作 taskMap）
    private let taskMapQueue = DispatchQueue(label: "com.example.KingfisherSessionDelegateViewController.TaskMapQueue")
    

    // 将indentierfer和task对应起来,
    // 构造一个信息更多的task
    func addTask(task: URLSessionDataTask, url: URL, onComplete: @escaping (Result<RetrieveImageResult, KFError>) -> Void) {
        taskMapQueue.sync {
            // 简单模式：每次请求都创建一个新的 Task，不进行合并
            let sessionDataTask = KingfisherSessionDataTask()
            sessionDataTask.task = task
            sessionDataTask.onCallback = onComplete
            tasks[task.taskIdentifier] = sessionDataTask
        }
    }

}

extension KingfisherSessionDelegate: URLSessionDataDelegate {

    
    
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
        print("1️⃣:接收响应头:\(dataTask.taskIdentifier)")
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
        print("2️⃣:接受数据:\(dataTask.taskIdentifier)")
        taskMapQueue.sync {
            
            guard let task = tasks[dataTask.taskIdentifier] else {
                
                return
            }
            
            task.appendData(data: data)
//            guard var (url, task) = tasks[]
            // 安全获取任务信息
//            guard var (existingData, progressBlock, completionBlock) = taskMap[dataTask] else { return }
            
            // 累积数据
//            existingData.append(data)
            
            // 更新任务信息
//            taskMap[dataTask] = (existingData, progressBlock, completionBlock)
            
            // 计算进度
            if let response = dataTask.response as? HTTPURLResponse,
               let expectedLength = response.expectedContentLength as Int64? {
//                let progress = Double(existingData.count) / Double(expectedLength)
                // 调用进度回调
//                progressBlock?(progress)
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
        print("3️⃣:任务完成:\(task.taskIdentifier)")
        taskMapQueue.sync {
            
            // 1. 先查找 Task。如果这里没找到，说明我们根本不知道这个任务是谁发起的，
            // 也就没有回调闭包可用，所以这种情况下确实无法回调。
            // 但在正常流程中，只要任务启动了，这里一定能找到。
            guard let sessionTask = tasks[task.taskIdentifier] else {
                return
            }
            
            // 2. 无论成功失败，任务结束了都要清理，防止内存泄漏
            tasks.removeValue(forKey: task.taskIdentifier)
        
            // 3. 处理结果并回调
            if let error = error {
                // 失败回调
                sessionTask.onCallback?(.failure(.responseError(reason: .URLSessionError(error: error))))
            } else {
                // 成功回调
                let result = Result<RetrieveImageResult, KFError>.success(.init(data: sessionTask.data, cacheType: .none))
                sessionTask.onCallback?(result)
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
    
}
