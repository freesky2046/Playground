//
//  RouteParser.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/9.
//

import Foundation

class RouteParser {

    func parseScheme(url: URL) throws -> String {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw  RouteError.invalidURL(url.absoluteString)
        }
        return url.scheme ?? ""
    }

    func parse(url: URL) throws -> (String, [String: String]) {
        guard let uRLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw  RouteError.invalidURL(url.absoluteString)
        }
        
        let host = uRLComponents.host ?? ""
   
        var params: [String: String] = [:]
        uRLComponents.queryItems?.forEach { item in
            if let value = item.value {
                params[item.name] = value
            }
        }
        return (host, params)
    }
}
