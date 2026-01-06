//
//  RequestParameter.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/5/26.
//

import Foundation

public enum RequestParameter {
    case query([URLQueryItem])
    case body(Encodable)
    case none
}
