//
//  KingfisherSessionDataTask.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import Foundation

class KingfisherSessionDataTask {
    private var lock = NSLock()
    private var _task: URLSessionDataTask?
    private var _data: NSMutableData = NSMutableData()
    
    
    var onCallback: ((Result<RetrieveImageResult, KFError>) -> Void)?
    
    var data: NSMutableData? {
        get {
            var result: NSMutableData? = nil
            lock.lock()
            result = _data
            lock.unlock()
            return result
        }
         set {
             lock.lock()
             _data = newValue ?? NSMutableData()
             lock.unlock()
         }
    }
    
    var task: URLSessionDataTask? {
        get {
            var result: URLSessionDataTask? = nil
            lock.lock()
            result = _task
            lock.unlock()
            return result
        }
         set {
             lock.lock()
             _task = newValue
             lock.unlock()
         }
    }
    
    func appendData(data: Data) {
        self.data?.append(data)
    }
    
    func isSame(task: URLSessionTask?)-> Bool {
        var result: Bool = false
        lock.lock()
         result = self.task?.taskIdentifier == task?.taskIdentifier &&  task != nil
        lock.unlock()
        return result
    }
    
}
