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
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15.0
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
    func sendCodable<T: Codable>(_ convertible: any URLConvertible,
              method: HTTPMethod = .get,
              parameters: Parameters? = nil,
              encoding: any ParameterEncoding = URLEncoding.default,
              headers: HTTPHeaders? = nil,
              interceptor: (any RequestInterceptor)? = nil,
              requestModifier: RequestModifier? = nil,
              completionHandler: @escaping @Sendable (Result<T, AFError>) -> Void ) -> DataRequest {
        let dataRequest = request(convertible, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor, requestModifier: requestModifier)
        return dataRequest.validate().responseData {[weak self] res in
            self?.handleResponse(res: res, completionHandler: completionHandler)
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
                                                                  completionHandler: @escaping @Sendable (Result<T, AFError>) -> Void ) -> DataRequest {
        let dataRequest = request(convertible, method: method, parameters: parameters, encoder: encoder, interceptor: interceptor, requestModifier: requestModifier)
        return dataRequest.validate().responseData {[weak self] res in
            self?.handleResponse(res: res, completionHandler: completionHandler)
        }
    }
    
    // 1. URLRequestConvertible 对象
    func sendCodable<T: Codable>(_ convertible: any URLRequestConvertible, interceptor: (any RequestInterceptor)? = nil, completionHandler: @escaping @Sendable (Result<T, AFError>) -> Void) -> DataRequest {
        let dataRequest =  request(convertible, interceptor: interceptor)
        return dataRequest.validate().responseData {[weak self] res in
            self?.handleResponse(res: res, completionHandler: completionHandler)
        }
    }
    
    // 2. URLRequestConvertible 对象便利方法（不含interceptor，直接调用核心方法）
    func sendCodable<T: Codable>(_ convertible: any URLRequestConvertible,
                                 completionHandler: @escaping @Sendable (Result<T, AFError>) -> Void) -> DataRequest {
        // 复用核心方法，仅省略interceptor参数（用默认值nil）
        return self.sendCodable(convertible,
                                interceptor: nil,
                                completionHandler: completionHandler)
    }
    
    private func handleResponse<T: Codable>(res: AFDataResponse<Data>, completionHandler: @escaping @Sendable (Result<T, AFError>) -> Void) {
        // 这里再拦截一些代码做一些处理
        // 譬如本地日志,远程上报
        // 往上不需要抛 AFDataResponse<Data> 这样的对象,而是响应结果Data, Error报上来就好
        logResponse(response: res)
        report()
        switch res.result {
        case .success(let data):
            let coder = JSONDecoder()
            do  {
                let jsonData = try coder.decode(T.self, from: data)
                completionHandler(.success(jsonData))
            } catch {
                completionHandler(.failure(AFError.responseSerializationFailed(reason: .inputFileNil)))
            }
        case .failure(let error):
            completionHandler(.failure(error))
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
