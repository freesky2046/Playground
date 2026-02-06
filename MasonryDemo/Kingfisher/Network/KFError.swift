//
//  KFError.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import Foundation

enum KFError: Error {
    case taskdeInitError
    case responseError(reason: ResponseErrorReason)
    
    enum ResponseErrorReason {
        case URLSessionError(error: Error)
    }
}
