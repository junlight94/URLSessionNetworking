//
//  NetworkClient.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/5/26.
//

import Foundation

public protocol NetworkClient {
    func send<R: Request>(with request: R) async throws -> R.Response
}
