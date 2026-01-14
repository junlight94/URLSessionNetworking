//
//  RequestTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/8/26.
//

import Testing
import Foundation
@testable import URLSessionNetworking

@MainActor
struct RequestTests {
    
    // MARK: - Test Request Implementation
    
    struct TestRequest: Request {
        typealias Response = TestResponse
        
        struct TestResponse: Codable, Sendable {
            let value: String
        }
        
        var header: [HTTPHeader]
        var path: String
        var method: HTTPMethod
        var parameter: RequestParameter
        var timeoutInterval: TimeInterval?
        var maxRetryAttempts: Int
    }
    
    @Test("URL이 baseURL과 path를 결합하여 생성되는지 확인")
    func createsURLFromBaseURLAndPath() async throws {
        let request = TestRequest(
            header: [],
            path: "/api/users",
            method: .get,
            parameter: .none,
            timeoutInterval: nil,
            maxRetryAttempts: 3
        )
        
        let urlRequest = try request.asRequest()
        
        #expect(urlRequest.url?.absoluteString == "https://test-api.com/api/users")
    }
    
    @Test("HTTP 메서드가 올바르게 설정되는지 확인")
    func setsHTTPMethod() async throws {
        let methods: [(HTTPMethod, String)] = [
            (.get, "GET"),
            (.post, "POST"),
            (.put, "PUT"),
            (.delete, "DELETE"),
            (.patch, "PATCH")
        ]
        
        for (method, expected) in methods {
            let request = TestRequest(
                header: [],
                path: "/test",
                method: method,
                parameter: .none,
                timeoutInterval: nil,
                maxRetryAttempts: 3
            )
            
            let urlRequest = try request.asRequest()
            #expect(urlRequest.httpMethod == expected)
        }
    }
    
    @Test("헤더가 올바르게 추가되는지 확인")
    func addsHeaders() async throws {
        let headers = [
            HTTPHeader(name: "X-Custom", value: "value1"),
            HTTPHeader(name: "X-Another", value: "value2")
        ]
        
        let request = TestRequest(
            header: headers,
            path: "/test",
            method: .get,
            parameter: .none,
            timeoutInterval: nil,
            maxRetryAttempts: 3
        )
        
        let urlRequest = try request.asRequest()
        
        #expect(urlRequest.value(forHTTPHeaderField: "X-Custom") == "value1")
        #expect(urlRequest.value(forHTTPHeaderField: "X-Another") == "value2")
    }
    
    @Test("타임아웃이 설정되는지 확인")
    func setsTimeoutInterval() async throws {
        let request = TestRequest(
            header: [],
            path: "/test",
            method: .get,
            parameter: .none,
            timeoutInterval: 30.0,
            maxRetryAttempts: 3
        )
        
        let urlRequest = try request.asRequest()
        
        #expect(urlRequest.timeoutInterval == 30.0)
    }
    
    @Test("타임아웃이 nil이면 기본값 사용")
    func usesDefaultTimeoutWhenNil() async throws {
        let request = TestRequest(
            header: [],
            path: "/test",
            method: .get,
            parameter: .none,
            timeoutInterval: nil,
            maxRetryAttempts: 3
        )
        
        let urlRequest = try request.asRequest()
        
        // URLRequest의 기본 타임아웃은 60초
        #expect(urlRequest.timeoutInterval == 60.0)
    }
    
    @Test("JSON 파라미터가 인코딩되는지 확인")
    func encodesJSONParameters() async throws {
        struct TestParams: Codable, Sendable {
            let name: String
            let age: Int
        }
        
        let params = TestParams(name: "Test", age: 30)
        let request = TestRequest(
            header: [],
            path: "/test",
            method: .post,
            parameter: .jsonBody(params),
            timeoutInterval: nil,
            maxRetryAttempts: 3
        )
        
        let urlRequest = try request.asRequest()
        
        #expect(urlRequest.httpBody != nil)
        let decoded = try JSONDecoder().decode(TestParams.self, from: urlRequest.httpBody!)
        #expect(decoded.name == "Test")
        #expect(decoded.age == 30)
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }
    
    @Test("쿼리 파라미터가 인코딩되는지 확인")
    func encodesQueryParameters() async throws {
        struct TestParams: Codable, Sendable {
            let name: String
            let age: Int
        }
        
        let params = TestParams(name: "Test", age: 30)
        let request = TestRequest(
            header: [],
            path: "/test",
            method: .get,
            parameter: .query(params),
            timeoutInterval: nil,
            maxRetryAttempts: 3
        )
        
        let urlRequest = try request.asRequest()
        
        let components = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.count == 2)
        
        let nameItem = components?.queryItems?.first { $0.name == "name" }
        #expect(nameItem?.value == "Test")
        
        let ageItem = components?.queryItems?.first { $0.name == "age" }
        #expect(ageItem?.value == "30")
    }
    
    @Test("maxRetryAttempts 기본값이 3인지 확인")
    func hasDefaultMaxRetryAttempts() async throws {
        struct SimpleRequest: Request {
            var maxRetryAttempts: Int = 3
            
            typealias Response = String
            
            var header: [HTTPHeader] { [] }
            var path: String { "/test" }
            var method: HTTPMethod { .get }
            var parameter: RequestParameter { .none }
            var timeoutInterval: TimeInterval? { nil }
        }
        
        let request = SimpleRequest()
        #expect(request.maxRetryAttempts == 3)
    }
}
