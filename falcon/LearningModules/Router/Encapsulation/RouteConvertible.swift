//
//  RouteConvertible.swift
//  falcon
//
//  Created by 周明 on 2026/2/11.
//

import Foundation

protocol RouteConvertible: CaseIterable {
    var host: String { get }
    var target: any RouteCompatible.Type { get }
}
