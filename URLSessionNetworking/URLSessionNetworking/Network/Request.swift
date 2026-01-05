//
//  Request.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/5/26.
//

import Foundation

public protocol Request {
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    
}
