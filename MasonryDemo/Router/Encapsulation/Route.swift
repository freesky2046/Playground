//
//  Route.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/9.
//

import UIKit

enum Route: CaseIterable {
    case home
    case alamofire
    case kingfisher
    case yytext
    case yycache
    case kingfisherBaisc
    case basicKnowledge
    case thirdParty
}

extension Route {
    var host: String {
        switch self {
        case .alamofire:
            "alamofire"
        case .kingfisher:
            "kingfisher"
        case .yytext:
            "yytext"
        case .yycache:
            "yycache"
        case .home:
            "home"
        case .kingfisherBaisc:
            "kingfisherBaisc"
        case .basicKnowledge:
            "basicKnowledge"
        case .thirdParty:
            "thirdParty"
        }
    }
    
    var target: any RouteCompatible.Type {
        switch self {
        case .home:
           return HomeViewController.self
        case .alamofire:
            return AlamofireViewController.self
        case .kingfisher:
           return KingfisherViewController.self
        case .yytext:
            return YYTextController.self
        case .yycache:
            return CacheUsageViewController.self
        case .kingfisherBaisc:
            return KingfisherBasicViewController.self
        case .basicKnowledge:
            return BasicKnowledgeViewController.self
        case .thirdParty:
            return UsageThirdPartyViewController.self
        }
    }
}
