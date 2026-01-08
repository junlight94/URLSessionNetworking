//
//  RequestInterceptor.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/8/26.
//

import Foundation

/// RequestAdapter와 RequestRetrier를 통합한 인터셉터 프로토콜
public protocol RequestInterceptor: RequestAdapter, RequestRetrier {}

/// 기본 인터셉터 구현
public struct DefaultInterceptor: RequestInterceptor {
    private let adapters: [RequestAdapter]
    private let retrier: RequestRetrier?
    
    public init(
        adapters: [RequestAdapter] = [],
        retrier: RequestRetrier? = nil
    ) {
        self.adapters = adapters
        self.retrier = retrier
    }
    
    public func retry(_ request: URLRequest, dueTo error: any Error, retryCount: Int) async throws -> RetryResult {
        guard let retrier else {
            return .doNotRetry
        }
        
        return try await retrier.retry(
            request,
            dueTo: error,
            retryCount: retryCount
        )
    }
    
    public func adapt(_ urlRequest: URLRequest) async throws -> URLRequest {
        var request = urlRequest
        
        for adapter in adapters {
            request = try await adapter.adapt(request)
        }
        
        return request
    }
}
