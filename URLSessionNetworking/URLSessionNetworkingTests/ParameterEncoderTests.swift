//
//  ParameterEncoderTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/8/26.
//

import Testing
import Foundation
@testable import URLSessionNetworking

@MainActor
struct ParameterEncoderTests {
    
    // MARK: - JSONParameterEncoder
    
    @Test("JSONParameterEncoder - nil 파라미터는 요청을 그대로 반환")
    func jsonEncoderWithNilParameters() async throws {
        let encoder = JSONParameterEncoder()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        
        let result = try encoder.encode(nil as String?, into: request)
        
        #expect(result.httpBody == nil)
    }
    
    @Test("JSONParameterEncoder - 파라미터를 JSON으로 인코딩하여 httpBody에 설정")
    func jsonEncoderEncodesParameters() async throws {
        struct TestParams: Codable, Sendable {
            let name: String
            let age: Int
        }
        
        let encoder = JSONParameterEncoder()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let params = TestParams(name: "Test", age: 30)
        
        let result = try encoder.encode(params, into: request)
        
        #expect(result.httpBody != nil)
        let decoded = try JSONDecoder().decode(TestParams.self, from: result.httpBody!)
        #expect(decoded.name == "Test")
        #expect(decoded.age == 30)
    }
    
    @Test("JSONParameterEncoder - Content-Type 헤더 자동 추가")
    func jsonEncoderAddsContentTypeHeader() async throws {
        struct TestParams: Codable, Sendable {
            let value: String
        }
        
        let encoder = JSONParameterEncoder()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let params = TestParams(value: "test")
        
        let result = try encoder.encode(params, into: request)
        
        #expect(result.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }
    
    @Test("JSONParameterEncoder - 이미 Content-Type이 있으면 추가하지 않음")
    func jsonEncoderDoesNotOverrideExistingContentType() async throws {
        struct TestParams: Codable, Sendable {
            let value: String
        }
        
        let encoder = JSONParameterEncoder()
        let url = URL(string: "https://example.com")!
        var request = URLRequest(url: url)
        request.setValue("custom/type", forHTTPHeaderField: "Content-Type")
        let params = TestParams(value: "test")
        
        let result = try encoder.encode(params, into: request)
        
        #expect(result.value(forHTTPHeaderField: "Content-Type") == "custom/type")
    }
    
    // MARK: - URLQueryEncoder
    
    @Test("URLQueryEncoder - nil 파라미터는 요청을 그대로 반환")
    func urlQueryEncoderWithNilParameters() async throws {
        let encoder = URLQueryEncoder()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        
        let result = try encoder.encode(nil as String?, into: request)
        
        #expect(result.url == url)
    }
    
    @Test("URLQueryEncoder - 파라미터를 쿼리스트링으로 변환")
    func urlQueryEncoderConvertsToQueryString() async throws {
        struct TestParams: Codable, Sendable {
            let name: String
            let age: Int
        }
        
        let encoder = URLQueryEncoder()
        let url = URL(string: "https://example.com/api")!
        let request = URLRequest(url: url)
        let params = TestParams(name: "Test", age: 30)
        
        let result = try encoder.encode(params, into: request)
        
        #expect(result.url != nil)
        let components = URLComponents(url: result.url!, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.count == 2)
        
        let nameItem = components?.queryItems?.first { $0.name == "name" }
        #expect(nameItem?.value == "Test")
        
        let ageItem = components?.queryItems?.first { $0.name == "age" }
        #expect(ageItem?.value == "30")
    }
    
    @Test("URLQueryEncoder - URL이 없으면 요청을 그대로 반환")
    func urlQueryEncoderWithNoURL() async throws {
        struct TestParams: Codable, Sendable {
            let value: String
        }
        
        let encoder = URLQueryEncoder()
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.url = nil
        let params = TestParams(value: "test")
        
        let result = try encoder.encode(params, into: request)
        
        #expect(result.url == nil)
    }
    
    // MARK: - EmptyEncoder
    
    @Test("EmptyEncoder - 요청을 그대로 반환")
    func emptyEncoderReturnsRequestAsIs() async throws {
        struct TestParams: Codable, Sendable {
            let value: String
        }
        
        let encoder = EmptyEncoder()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let params = TestParams(value: "test")
        
        let result = try encoder.encode(params, into: request)
        
        #expect(result.url == url)
        #expect(result.httpBody == nil)
    }
}
