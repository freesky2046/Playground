//
//  SimpleRouter.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/9.
//

import Foundation
import UIKit

class SimpleRouter {
    enum NavigationerType {
        case push
        case present
    }

    var scheme: String = "md"
    private var routeMap: [String: Route] = [:]
    private var parser: RouteParser = RouteParser()
    
    static var  shared: SimpleRouter = SimpleRouter()
    
    private init() {
        registerRoute()
    }
    
    private func registerRoute() {
        for route in Route.allCases {
            routeMap[route.host.lowercased()] = route
        }
    }
    
    func route(url: String, navigationType: NavigationerType = .push, animated: Bool = true) throws {
        guard let URL: URL = URL(string: url) else {
            throw RouteError.invalidURL(url)
        }
        try route(url: URL, navigationType: navigationType, animated: animated)
    }
    
    func route(url: URL, navigationType: NavigationerType = .push, animated: Bool = true ) throws {
        let scheme  = try parser.parseScheme(url: url)
        guard scheme == self.scheme else {
            throw RouteError.invalidScheme(scheme)
        }
        let (host, params) =  try parser.parse(url: url)
        guard let route = routeMap[host.lowercased()] else {
            throw RouteError.notFoundPath(host)
        }
        switch navigationType {
        case .push:
            Navigationer.push(targetVCType: route.target , params: params, animated: animated)
        case .present:
            Navigationer.present(targetVCType: route.target, params: params,animated: animated)
            
        }
    }
    
}

extension SimpleRouter {
    func to(url: String, navigationType: NavigationerType = .push, animated: Bool = true) {
        try? route(url: url, navigationType: navigationType, animated: animated)
    }
}
