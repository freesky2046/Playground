//
//  NetworkInterceptor.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/26.
//

import Foundation
import Alamofire


 class NetworkInterceptor: RequestInterceptor, @unchecked Sendable {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var request = urlRequest
        guard let url = urlRequest.url else {
            return  completion(.failure(AFError.parameterEncodingFailed(reason: .missingURL)))
         
        }
        ///  拼接query
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !NetworkConfig.commonQuery.isEmpty {
            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + NetworkConfig.commonQuery
            urlComponents.percentEncodedQuery = percentEncodedQuery
            request.url = urlComponents.url
        }
        
        ///  添加headers
        request.allHTTPHeaderFields = NetworkConfig.commonHeaders.dictionary
        
        return completion(.success(request))
    }
    
    func retry(_ request: Request,
                      for session: Session,
                      dueTo error: any Error,
                      completion: @escaping @Sendable (RetryResult) -> Void) {
        guard let response =  request.task?.response as? HTTPURLResponse else {
            return completion(.doNotRetry)
        }
        if response.statusCode == 401 {
            // 获取登陆框
            LoginUti.login()
        }
        completion(.doNotRetry)
    }
}

struct LoginUti {
    
    static func login() {
        /// ⚠️要判断当前控制器是否已是登陆框,若是,不要再次唤起登陆框,直接return
        DispatchQueue.main.async(execute: {
            print("执行登陆")
        })
    }
}
