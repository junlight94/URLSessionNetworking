//
//  HeaderAdapterTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/8/26.
//

import Testing
import Foundation
@testable import URLSessionNetworking

@MainActor
struct HeaderAdapterTests {
    
    @Test("기본 헤더가 요청에 추가되는지 확인")
    func addsDefaultHeaders() async throws {
        let adapter = HeaderAdapter()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        
        let result = try await adapter.adapt(request)
        
        #expect(result.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(result.value(forHTTPHeaderField: "X-Platform") == "iOS")
        #expect(result.value(forHTTPHeaderField: "X-App-Version") != nil)
    }
    
    @Test("기존 헤더를 덮어쓰는지 확인")
    func overridesExistingHeaders() async throws {
        let adapter = HeaderAdapter()
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.setValue("android", forHTTPHeaderField: "X-Platform")
        
        let result = try await adapter.adapt(request)
        
        // 기본 헤더로 덮어쓰여야 함
        #expect(result.value(forHTTPHeaderField: "X-Platform") == "iOS")
    }
    
    @Test("기존 헤더와 다른 헤더는 유지되는지 확인")
    func preservesOtherHeaders() async throws {
        let adapter = HeaderAdapter()
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.setValue("custom-value", forHTTPHeaderField: "X-Custom")
        
        let result = try await adapter.adapt(request)
        
        // 기본 헤더는 추가되고
        #expect(result.value(forHTTPHeaderField: "Accept") == "application/json")
        // 기존 커스텀 헤더는 유지되어야 함
        #expect(result.value(forHTTPHeaderField: "X-Custom") == "custom-value")
    }
}
