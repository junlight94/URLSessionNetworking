//
//  RequestAdapter.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/8/26.
//

import Foundation

/// 요청 전에 URLRequest를 수정하는 어댑터
///
/// 네트워크 요청이 전송되기 전에 요청을 수정할 수 있습니다.
/// 예: 헤더 추가, 인증 토큰 주입, URL 수정 등
public protocol RequestAdapter: Sendable {
    /// 요청을 수정합니다.
    ///
    /// - Parameter urlRequest: 수정할 URLRequest
    /// - Returns: 수정된 URLRequest
    /// - Throws: 요청 수정 중 발생한 에러
    func adapt(_ urlRequest: URLRequest) async throws -> URLRequest
}

struct HeaderAdapter: RequestAdapter {
    
    private let headers: [HTTPHeader]
    
    public init() {
        self.headers = NetworkConfiguration.defaultHeader
    }
    
    public func adapt(_ urlRequest: URLRequest) async throws -> URLRequest {
        var request = urlRequest
        
        // 동일한 헤더가 있으면 덮어쓰고 설정
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.name)
        }
        return request
    }
}

struct AuthAdapter: RequestAdapter {
    
    private let tokenProvider: TokenProvider
    
    public init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    public func adapt(_ urlRequest: URLRequest) async throws -> URLRequest {
        var request = urlRequest
        let accessToken = await tokenProvider.accessToken()
        request.header(.authorization(accessToken))
        return request
    }
}

// TODO: 임시 코드
public protocol TokenProvider: Sendable {
    func accessToken() async -> String
}
