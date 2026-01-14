//
//  Session.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/8/26.
//

import Foundation

public struct Session: Sendable {
    public let session: URLSession
    public let configuration: URLSessionConfiguration
    public let interceptor: RequestInterceptor
    
    init(
        configuration: URLSessionConfiguration,
        interceptor: RequestInterceptor
    ) {
        self.session = URLSession(configuration: configuration)
        self.configuration = configuration
        self.interceptor = interceptor
    }
    
    /// 요청을 어댑터로 수정 후 전송하고, 실패 시 재시도 로직 수행
    /// - Parameters:
    ///   - originalRequest: 원본 요청
    ///   - retryCount: 현재 재시도 횟수
    /// - Returns: 응답 데이터와 URLResponse
    func requestData(
        _ originalRequest: URLRequest,
        retryCount: Int = 0
    ) async throws -> (data: Data, urlResponse: URLResponse)  {
        let adaptedRequest = try await interceptor.adapt(originalRequest)

        do {
            let (data, urlResponse) = try await session.data(for: adaptedRequest)
            return (data, urlResponse)
        } catch {
            let decision = try await interceptor.retry(
                adaptedRequest,
                dueTo: error,
                retryCount: retryCount
            )
            
            switch decision {
            case .retry:
                return try await requestData(
                    originalRequest,
                    retryCount: retryCount + 1
                )
                
            case .retryWithDelay(let delay):
                try await Task.sleep(for: .seconds(delay))
                return try await requestData(
                    originalRequest,
                    retryCount: retryCount + 1
                )
                
            case .doNotRetry:
                throw error
                
            case .doNotRetryWithError(let error):
                throw error
            }
        }
    }
}

extension Session {
    public static let plain = Session(
        configuration: URLSessionConfiguration.default,
        interceptor: DefaultInterceptor(
            adapters: [HeaderAdapter()],
            retrier: DefaultRequestRetrier()
        )
    )
    
    public static func auth(tokenProvider: TokenProvider) -> Self {
        let interceptor = DefaultInterceptor(
            adapters: [
                HeaderAdapter(),
                AuthAdapter(tokenProvider: tokenProvider)
            ],
            retrier: DefaultRequestRetrier()
        )
        
        return Session(
            configuration: URLSessionConfiguration.default,
            interceptor: interceptor
        )
    }
}
