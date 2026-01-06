//
//  RequestParameter.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/5/26.
//

import Foundation

public struct RequestParameter {
    let value: Encodable & Sendable
    let encoder: ParameterEncoder
}

extension RequestParameter {
    static func query(_ query: Encodable & Sendable) -> RequestParameter {
        RequestParameter(
            value: query,
            encoder: URLQueryEncoder()
        )
    }

    static func jsonBody(_ body: Encodable & Sendable) -> RequestParameter {
        RequestParameter(
            value: body,
            encoder: JSONParameterEncoder()
        )
    }

    static let none: RequestParameter? = nil
}
