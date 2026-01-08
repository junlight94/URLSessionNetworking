//
//  Session.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/8/26.
//

import Foundation

public struct Session: Sendable {
    public let session: URLSession
    public let interceptor: RequestInterceptor
    
    private init(session: URLSession, interceptor: RequestInterceptor) {
        self.session = session
        self.interceptor = interceptor
    }
}

extension Session {
    public static let plain = Session(
        session: .shared,
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
        
        return Session(session: .shared, interceptor: interceptor)
    }
}
