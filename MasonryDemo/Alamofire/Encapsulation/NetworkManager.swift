//
//  NetworkManager.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/26.
//

import Foundation
import Alamofire

public typealias RequestModifier = @Sendable (inout URLRequest) throws -> Void

class NetworkManager {
    static let shared = NetworkManager()
    
    // 配置Session并持有强引用
    let session: Session
    let cacheManager = CacheManager.shared
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15.0
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let interceptor = NetworkInterceptor()
        // 初始化Session并强引用持有
        session = Session(configuration: configuration, interceptor: interceptor)
    }
    
   //  MARK: - ⚠️ 只发送请求,不做响应回调完成拦截的公共处理
    
   // 字典参数, urlstring,url
   func request(_ convertible: any URLConvertible,
                      method: HTTPMethod = .get,
                      parameters: Parameters? = nil,
                      encoding: any ParameterEncoding = URLEncoding.default,
                      headers: HTTPHeaders? = nil,
                      interceptor: (any RequestInterceptor)? = nil,
                 requestModifier: RequestModifier? = nil) -> DataRequest {
        let request = session.request(convertible, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor, requestModifier: requestModifier)
        logRequest(reqeust: request)
        return request
    }
    
    // 模型参数, urlstring, url
    func request<Parameters: Encodable & Sendable>(_ convertible: any URLConvertible,
                                                        method: HTTPMethod = .get,
                                                        parameters: Parameters? = nil,
                                                        encoder: any ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                                        headers: HTTPHeaders? = nil,
                                                        interceptor: (any RequestInterceptor)? = nil,
                                                   requestModifier: RequestModifier? = nil) -> DataRequest {
        let request = session.request(convertible, method: method, parameters: parameters, encoder: encoder, headers: headers, interceptor: interceptor, requestModifier: requestModifier)
        logRequest(reqeust: request)
        return request
    }
    
    //
    func request(_ convertible: any URLRequestConvertible, interceptor: (any RequestInterceptor)? = nil) -> DataRequest {
        let request =  session.request(convertible, interceptor: interceptor)
        logRequest(reqeust: request)
        return request
    }
    
      
    //  MARK: - ⚠️  请求后自己解析响应,只将Data,Error往上抛给业务层, 同时可以拦截做一些额外操作
    // 字典参数, urlstring,url
    @discardableResult
    func sendCodable<T: Codable>(_ convertible: any URLConvertible,
              method: HTTPMethod = .get,
              parameters: Parameters? = nil,
              encoding: any ParameterEncoding = URLEncoding.default,
              headers: HTTPHeaders? = nil,
              interceptor: (any RequestInterceptor)? = nil,
              requestModifier: RequestModifier? = nil,
              decodeType: T.Type,
              needCache: Bool = false,
              completionHandler: @escaping @Sendable (Result<T, AFError>) -> Void ) -> DataRequest {
        let dataRequest = request(convertible, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor, requestModifier: requestModifier)
        return dataRequest.validate().responseData {[weak self] res in
            self?.handleResponse(res: res, decodeType: decodeType, needCache: needCache,completionHandler: completionHandler)
        }
    }
    
    
    // 模型参数, urlstring, url
    func sendCoable<T: Codable, Parameters: Encodable & Sendable>(_ convertible: any URLConvertible,
                                                                  method: HTTPMethod = .get,
                                                                  parameters: Parameters? = nil,
                                                                  encoder: any ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                                                  headers: HTTPHeaders? = nil,
                                                                  interceptor: (any RequestInterceptor)? = nil,
                                                                  requestModifier: RequestModifier? = nil,
                                                                  decodeType: T.Type,
                                                                  needCache: Bool = false,
                                                                  completionHandler: @escaping @Sendable (Result<T, AFError>) -> Void ) -> DataRequest {
        let dataRequest = request(convertible, method: method, parameters: parameters, encoder: encoder, interceptor: interceptor, requestModifier: requestModifier)
        return dataRequest.validate().responseData {[weak self] res in
            self?.handleResponse(res: res, decodeType: decodeType, needCache: needCache, completionHandler: completionHandler)
        }
    }
    
    // 1. URLRequestConvertible 对象
    func sendCodable<T: Codable>(_ convertible: any URLRequestConvertible, decodeType: T.Type, interceptor: (any RequestInterceptor)? = nil, needCache: Bool = false,completionHandler: @escaping @Sendable (Result<T, AFError>) -> Void) -> DataRequest {
        let dataRequest =  request(convertible, interceptor: interceptor)
        return dataRequest.validate().responseData {[weak self] res in
            self?.handleResponse(res: res, decodeType: decodeType, needCache: needCache, completionHandler: completionHandler)
        }
    }
    
    
    private func handleResponse<T: Codable>(
        res: AFDataResponse<Data>,
        decodeType: T.Type,
        needCache: Bool,
        completionHandler: @escaping @Sendable (Result<T, AFError>) -> Void
    ) {
        // 公共前置处理：日志和上报
        logResponse(response: res)
        report()
        
        // 核心逻辑：优先处理成功，失败时回退到缓存
        switch res.result {
        case .success(let data):
            // 成功时解码并缓存
            decodeAndComplete(data: data, decodeType: decodeType, completion: completionHandler)
            // 存储缓存（如果有请求和响应）
            if let request = res.request, let response = res.response {
                cacheManager.store(request: request, response: response, data: data, maxCacheAge: 5 * 24 * 60 * 60)
            }
        case .failure(let error):
            // 失败时尝试读取缓存（仅当 needCache 为 true）
            if needCache, let request = res.request, let cachedData = cacheManager.cachedData(request: request) {
                // 从缓存解码并完成
                decodeAndComplete(data: cachedData, decodeType: decodeType, completion: completionHandler)
            } else {
                // 无缓存或不需要缓存，直接返回失败
                completionHandler(.failure(error))
            }
        }
    }

    // 提取解码逻辑为私有方法，避免重复
    private func decodeAndComplete<T: Codable>(
        data: Data,
        decodeType: T.Type,
        completion: @escaping @Sendable (Result<T, AFError>) -> Void
    ) {
        let coder = JSONDecoder()
        coder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let jsonData = try coder.decode(decodeType, from: data)
            completion(.success(jsonData))
        } catch {
            completion(.failure(AFError.responseSerializationFailed(reason: .decodingFailed(error: error))))
        }
    }
}

//  MARK: - ⚠️  log
extension NetworkManager {
    func logRequest(reqeust: DataRequest) {
        
    }
    
    func logResponse(response: AFDataResponse<Data>) {
        let metrics = response.metrics
        
        
    }
}

extension NetworkManager {
    func report() {
        
    }
}
