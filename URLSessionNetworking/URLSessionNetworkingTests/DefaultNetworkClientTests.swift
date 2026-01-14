//
//  DefaultNetworkClientTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/8/26.
//

import Testing
import Foundation
@testable import URLSessionNetworking

@MainActor
struct DefaultNetworkClientTests {
    
    // MARK: - Mock Interceptor
    
    struct MockInterceptor: RequestInterceptor {
        var adaptResult: URLRequest?
        var retryResult: RetryResult = .doNotRetry
        
        func adapt(_ urlRequest: URLRequest) async throws -> URLRequest {
            return adaptResult ?? urlRequest
        }
        
        func retry(_ request: URLRequest, dueTo error: any Error, retryCount: Int) async throws -> RetryResult {
            return retryResult
        }
    }
    
    // MARK: - Mock URLProtocol
    
    class MockURLProtocol: URLProtocol {
        static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let handler = MockURLProtocol.requestHandler else {
                client?.urlProtocol(self, didFailWithError: NSError(domain: "MockError", code: -1))
                return
            }
            
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading() {}
    }
    
    // MARK: - Test Request
    
    struct TestRequest: Request {
        typealias Response = TestResponse
        
        struct TestResponse: Codable, Sendable {
            let value: String
        }
        
        var header: [HTTPHeader] { [] }
        var path: String { "/test" }
        var method: HTTPMethod { .get }
        var parameter: RequestParameter { .none }
        var timeoutInterval: TimeInterval? { nil }
        var maxRetryAttempts: Int { 3 }
    }
    
    // MARK: - Tests
    
    @Test("성공적인 요청이 응답을 디코딩하여 반환하는지 확인")
    func sendsRequestAndDecodesResponse() async throws {
        // Mock URLProtocol 설정
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try JSONEncoder().encode(TestRequest.TestResponse(value: "success"))
            return (response, data)
        }
        
        let session = URLSession(configuration: configuration)
        let interceptor = MockInterceptor()
        let testSession = Session(
            configuration: configuration,
            interceptor: interceptor
        )
        
        // Session의 session 프로퍼티를 교체할 수 없으므로, 직접 생성
        // 실제로는 Session 구조체를 수정해야 할 수도 있음
        // 여기서는 테스트용으로 간단하게 작성
        
        let client = DefaultNetworkClient(session: testSession)
        let request = TestRequest()
        
        let response = try await client.send(with: request)
        
        #expect(response.value == "success")
    }
    
    @Test("2xx가 아닌 상태 코드일 때 invalidStatusCode 에러 발생")
    func throwsErrorForNon2xxStatusCode() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        let interceptor = MockInterceptor()
        let testSession = Session(
            configuration: configuration,
            interceptor: interceptor
        )
        
        let client = DefaultNetworkClient(session: testSession)
        let request = TestRequest()
        
        do {
            _ = try await client.send(with: request)
            Issue.record("Expected NetworkError.invalidStatusCode")
        } catch NetworkError.invalidStatusCode(let code) {
            #expect(code == 404)
        } catch {
            Issue.record("Expected NetworkError.invalidStatusCode, got \(error)")
        }
    }
}
