//
//  BaseResponse.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/1/28.
//

import Foundation

struct BaseResponse<T>: Codable {
    var code: Int?
    var msg: String
}
