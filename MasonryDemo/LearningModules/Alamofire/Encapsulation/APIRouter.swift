//
//  APIRouter.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/22.
//

import Foundation
import Alamofire


/// 类似于 Moya 的 TargetType，定义一个 API 请求的所有必要信息
protocol APIRouter: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

extension APIRouter {
    // 默认实现，简化代码
    var encoding: ParameterEncoding {
        return method == .get ? URLEncoding.default : JSONEncoding.default
    }
    
    // 将 Router 转换为 URLRequest (Alamofire 需要这个)
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers?.dictionary
        return try encoding.encode(urlRequest, with: parameters)
    }
}
