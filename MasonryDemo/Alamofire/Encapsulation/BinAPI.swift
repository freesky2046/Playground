//
//  BinAPI.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/27.
//

import Foundation
import Alamofire

enum HttpBinAPI: APIRouter {
    var method: Alamofire.HTTPMethod  {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .anything:
            return .get
        }
    }
    
    case get
    case post
    case anything
    
    var baseURL: String  {
        return NetworkConfig.baseURL
    }
    var path: String  {
        switch self {
        case .get:
            "get"
        case .post:
            "post"
        case .anything:
            "anything"
        }
    }
    
    var headers: Alamofire.HTTPHeaders?  {
        return nil
    }
    var parameters: Alamofire.Parameters?  {
        return nil
    }
    
   
    
}
