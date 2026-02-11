//
//  NetworkError.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/29.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case networkError(AFError)
    case serverError(Int, String)
    case businessError(Int, String)
    case decodingError(Error)
}
