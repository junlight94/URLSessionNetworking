//
//  NetworkClient.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/5/26.
//

import Foundation

public protocol NetworkClient {
    func send<T: Decodable & Sendable>(with request: Request) async throws -> T
}

public final class DefaultNetworkClient: NetworkClient {
    public func send<T: Decodable & Sendable>(with request: Request) async throws -> T {
        return
    }
}
