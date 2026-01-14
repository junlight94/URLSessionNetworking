//
//  AuthAdapterTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/8/26.
//

import Testing
import Foundation
@testable import URLSessionNetworking

@MainActor
struct AuthAdapterTests {
    
    // MARK: - Mock TokenProvider
    
    struct MockTokenProvider: TokenProvider {
        let token: String
        
        func accessToken() async -> String {
            return token
        }
    }
    
    @Test("Authorization 헤더에 토큰이 추가되는지 확인")
    func addsAuthorizationHeader() async throws {
        let tokenProvider = MockTokenProvider(token: "test-token-123")
        let adapter = AuthAdapter(tokenProvider: tokenProvider)
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        
        let result = try await adapter.adapt(request)
        
        let authHeader = result.value(forHTTPHeaderField: "Authorization")
        #expect(authHeader == "test-token-123")
    }
    
    @Test("기존 Authorization 헤더를 덮어쓰는지 확인")
    func overridesExistingAuthorizationHeader() async throws {
        let tokenProvider = MockTokenProvider(token: "new-token-456")
        let adapter = AuthAdapter(tokenProvider: tokenProvider)
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.setValue("old-token", forHTTPHeaderField: "Authorization")
        
        let result = try await adapter.adapt(request)
        
        let authHeader = result.value(forHTTPHeaderField: "Authorization")
        #expect(authHeader == "new-token-456")
    }
    
    @Test("토큰 프로바이더에서 동적으로 토큰을 가져오는지 확인")
    func fetchesTokenDynamically() async throws {
        let counter = CallCounter()
        actor CallCounter {
            private(set) var value = 0
            func increment() -> Int {
                value += 1
                return value
            }
        }
        
        struct DynamicTokenProvider: TokenProvider {
            let counter: CallCounter
            
            func accessToken() async -> String {
                let current = await counter.increment()
                return "dynamic-token-\(current)"
            }
        }
        
        let tokenProvider = DynamicTokenProvider(counter: counter)
        let adapter = AuthAdapter(tokenProvider: tokenProvider)
        
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        
        let result1 = try await adapter.adapt(request)
        let result2 = try await adapter.adapt(request)
        
        #expect(result1.value(forHTTPHeaderField: "Authorization") == "dynamic-token-1")
        #expect(result2.value(forHTTPHeaderField: "Authorization") == "dynamic-token-2")
        #expect(await counter.value == 2)
    }
}
