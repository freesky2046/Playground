//
//  KingfisherDownloader.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import UIKit


class KingfisherDownloader {
    
 
    let session: URLSession
    let sessionDelegate: KingfisherSessionDelegate
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15.0
        sessionDelegate = KingfisherSessionDelegate()
        
//        sessionDelegate.onCompleted = { result in
//            switch result {
//            case .success((let data, let task)):
//                break
//            case .failure(let error):
//                break
//            }
//        }
//        sessionDelegate.onCompleted = { result in
//            switch result {
//            case .success(let data, let task):
//                break
//            case .failure(let error):
//                break
//            }
//            
//        }
        self.session = URLSession(configuration:configuration, delegate: sessionDelegate, delegateQueue: nil)
    }
    
    func download(url: String, onComplete: @escaping (Result<RetrieveImageResult, KFError>) -> Void) {
        let URL =  URL(string: url)!
        let task = session.dataTask(with: URL)
        sessionDelegate.addTask(task: task, url: URL, onComplete: onComplete)
        task.resume()
    }



}
