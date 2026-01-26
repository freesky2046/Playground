//
//  NetworkConfig.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/26.
//

import Foundation
import Alamofire

struct NetworkConfig {
    
    static var commonParam: [String: String] {
        var result: [String: String] = [:]
        result["platform"] = "iOS"
        result["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0" // 补充APP版本
        return result
    }
    
    static var commonQuery: String {
        let parameters = Self.commonParam
        var components: [(String, String)] = []
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            let item: (String, String) = (key, escape(value))
            components.append(item)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    static var commonHeaders: HTTPHeaders {
        return HTTPHeaders(["token": "12345"])
    }
    
    static var baseURL: String {
        return "https://httpbin.org/get"
    }
    
    static private func escape(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? string
    }
}
