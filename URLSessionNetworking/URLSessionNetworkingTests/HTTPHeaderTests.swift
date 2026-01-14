//
//  HTTPHeaderTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/8/26.
//

import Testing
import Foundation
@testable import URLSessionNetworking

@MainActor
struct HTTPHeaderTests {
    
    @Test("기본 생성자로 헤더 생성")
    func initializer() {
        let header = HTTPHeader(name: "X-Custom", value: "value")
        #expect(header.name == "X-Custom")
        #expect(header.value == "value")
    }
    
    @Test("Content-Type 헤더 팩토리 메서드")
    func contentType() {
        let header = HTTPHeader.contentType(.json)
        #expect(header.name == "Content-Type")
        #expect(header.value == "application/json")
    }
    
    @Test("User-Agent 헤더 팩토리 메서드")
    func userAgent() {
        let header = HTTPHeader.userAgent("MyApp/1.0")
        #expect(header.name == "User-Agent")
        #expect(header.value == "MyApp/1.0")
    }
    
    @Test("Authorization 헤더 팩토리 메서드")
    func authorization() {
        let header = HTTPHeader.authorization("token123")
        #expect(header.name == "Authorization")
        #expect(header.value == "token123")
    }
    
    @Test("Bearer 토큰 형식의 Authorization 헤더 생성")
    func authorizationBearerToken() {
        let header = HTTPHeader.authorization(bearerToken: "token123")
        #expect(header.name == "Authorization")
        #expect(header.value == "Bearer token123")
    }
    
    @Test("Hashable 프로토콜 동작 확인")
    func hashable() {
        let header1 = HTTPHeader(name: "X-Custom", value: "value")
        let header2 = HTTPHeader(name: "X-Custom", value: "value")
        let header3 = HTTPHeader(name: "X-Custom", value: "different")
        
        #expect(header1 == header2)
        #expect(header1 != header3)
    }
    
    @Test("URLRequest extension의 header 메서드 동작 확인")
    func urlRequestExtension() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let header = HTTPHeader(name: "X-Custom", value: "value")
        
        request.header(header)
        
        #expect(request.value(forHTTPHeaderField: "X-Custom") == "value")
    }
}
