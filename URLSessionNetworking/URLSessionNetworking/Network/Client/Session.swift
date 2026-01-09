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
    
    private init(
        configuration: URLSessionConfiguration,
        interceptor: RequestInterceptor
    ) {
        self.session = URLSession(configuration: configuration)
        self.configuration = configuration
        self.interceptor = interceptor
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
