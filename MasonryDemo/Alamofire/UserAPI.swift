//
//  UserAPI.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/22.
//

import Foundation
import Alamofire

enum UserAPI: APIRouter {
    case login(username: String)
    case userProfile(id: Int)
    case updateAvatar(Data)
    
    var baseURL: String {
        return "https://api.example.com/v1"
    }
    
    var path: String {
        switch self {
        case .login: return "/login"
        case .userProfile(let id): return "/users/\(id)"
        case .updateAvatar: return "/users/avatar"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .userProfile: return .get
        case .updateAvatar: return .post
        }
    }
    
    var headers: HTTPHeaders? {
        // 这里可以返回特定接口的 Header，通用 Header 交给 Adapter 处理
        return nil
    }
    
    var parameters: Parameters? {
        switch self {
        case .login(let username):
            return ["username": username]
        default:
            return nil
        }
    }
}
