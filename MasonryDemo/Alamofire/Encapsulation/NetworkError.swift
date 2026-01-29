//
//  NetworkError.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/29.
//

import Foundation
import Alamofire

enum NetworkError {
    case afError(error: AFError)
    case wrapperError // 返回的数据类型不是 BaseResponse<T: Codable> 类型
    case unkownError
}
