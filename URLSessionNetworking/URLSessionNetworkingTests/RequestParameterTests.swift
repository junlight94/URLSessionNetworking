//
//  RequestParameterTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/8/26.
//

import Testing
import Foundation
@testable import URLSessionNetworking

@MainActor
struct RequestParameterTests {
    
    @Test("query 팩토리 메서드가 URLQueryEncoder를 사용하는지 확인")
    func queryFactoryMethod() async throws {
        struct TestQuery: Codable, Sendable {
            let name: String
            let age: Int
        }
        
        let query = TestQuery(name: "Test", age: 30)
        let parameter = RequestParameter.query(query)
        
        // URLQueryEncoder를 사용하는지 확인
        let url = URL(string: "https://example.com/api")!
        let request = URLRequest(url: url)
        
        let result = try parameter.encoder.encode(parameter.value, into: request)
        
        // 쿼리스트링이 추가되었는지 확인
        #expect(result.url != nil)
        let components = URLComponents(url: result.url!, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.count == 2)
    }
    
    @Test("jsonBody 팩토리 메서드가 JSONParameterEncoder를 사용하는지 확인")
    func jsonBodyFactoryMethod() async throws {
        struct TestBody: Codable, Sendable {
            let name: String
            let age: Int
        }
        
        let body = TestBody(name: "Test", age: 30)
        let parameter = RequestParameter.jsonBody(body)
        
        // JSONParameterEncoder를 사용하는지 확인
        let url = URL(string: "https://example.com/api")!
        let request = URLRequest(url: url)
        
        let result = try parameter.encoder.encode(parameter.value, into: request)
        
        // httpBody가 설정되고 Content-Type이 추가되었는지 확인
        #expect(result.httpBody != nil)
        #expect(result.value(forHTTPHeaderField: "Content-Type") == "application/json")
        
        let decoded = try JSONDecoder().decode(TestBody.self, from: result.httpBody!)
        #expect(decoded.name == "Test")
        #expect(decoded.age == 30)
    }
    
    @Test("none이 EmptyEncoder를 사용하는지 확인")
    func noneUsesEmptyEncoder() async throws {
        let parameter = RequestParameter.none
        
        let url = URL(string: "https://example.com/api")!
        let request = URLRequest(url: url)
        
        let result = try parameter.encoder.encode(parameter.value, into: request)
        
        // 요청이 그대로 반환되는지 확인
        #expect(result.url == url)
        #expect(result.httpBody == nil)
    }
}
