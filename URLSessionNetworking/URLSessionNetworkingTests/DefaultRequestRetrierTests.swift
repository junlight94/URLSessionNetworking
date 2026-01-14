//
//  DefaultRequestRetrierTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/8/26.
//

import Testing
import Foundation
@testable import URLSessionNetworking

@MainActor
struct DefaultRequestRetrierTests {
    
    @Test("최대 재시도 횟수 초과 시 재시도하지 않음")
    func doesNotRetryWhenMaxRetryCountExceeded() async throws {
        let retrier = DefaultRequestRetrier(maxRetryCount: 3)
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let error = NetworkError.invalidStatusCode(500)
        
        let result = try await retrier.retry(request, dueTo: error, retryCount: 3)
        
        switch result {
        case .doNotRetry:
            #expect(true)
        default:
            #expect(false)
        }
    }
    
    @Test("재시도 가능한 상태 코드일 때 지연 후 재시도")
    func retriesWithDelayForRetryableStatusCode() async throws {
        let retrier = DefaultRequestRetrier(
            maxRetryCount: 3,
            retryableStatusCodes: [500, 502, 503],
            retryDelay: 1.0
        )
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let error = NetworkError.invalidStatusCode(500)
        
        let result = try await retrier.retry(request, dueTo: error, retryCount: 0)
        
        if case .retryWithDelay(let delay) = result {
            #expect(delay == 1.0)
        } else {
            Issue.record("Expected retryWithDelay, got \(result)")
        }
    }
    
    @Test("재시도 가능한 모든 상태 코드 테스트")
    func retriesForAllRetryableStatusCodes() async throws {
        let retrier = DefaultRequestRetrier()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let retryableCodes = [408, 429, 500, 502, 503, 504]
        
        for statusCode in retryableCodes {
            let error = NetworkError.invalidStatusCode(statusCode)
            let result = try await retrier.retry(request, dueTo: error, retryCount: 0)
            
            if case .retryWithDelay = result {
                // 성공
            } else {
                Issue.record("Expected retryWithDelay for status code \(statusCode), got \(result)")
            }
        }
    }
    
    @Test("재시도 불가능한 상태 코드일 때 재시도하지 않음")
    func doesNotRetryForNonRetryableStatusCode() async throws {
        let retrier = DefaultRequestRetrier()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let error = NetworkError.invalidStatusCode(404)
        
        let result = try await retrier.retry(request, dueTo: error, retryCount: 0)
        
        switch result {
        case .doNotRetry:
            #expect(true)
        default:
            #expect(false)
        }
    }
    
    @Test("NetworkError.invalidStatusCode가 아닌 에러일 때 재시도하지 않음")
    func doesNotRetryForNonStatusCodeError() async throws {
        let retrier = DefaultRequestRetrier()
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let error = NetworkError.decodingFailure
        
        let result = try await retrier.retry(request, dueTo: error, retryCount: 0)
        
        switch result {
        case .doNotRetry:
            #expect(true)
        default:
            #expect(false)
        }
    }
    
    @Test("커스텀 최대 재시도 횟수 설정")
    func customMaxRetryCount() async throws {
        let retrier = DefaultRequestRetrier(maxRetryCount: 5)
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let error = NetworkError.invalidStatusCode(500)
        
        // 4번째 재시도까지는 허용
        let result1 = try await retrier.retry(request, dueTo: error, retryCount: 4)
        if case .retryWithDelay = result1 {
            // 성공
        } else {
            Issue.record("Expected retryWithDelay for retryCount 4, got \(result1)")
        }
        
        // 5번째 재시도는 거부
        let result2 = try await retrier.retry(request, dueTo: error, retryCount: 5)
        switch result2 {
        case .doNotRetry:
            #expect(true)
        default:
            #expect(false)
        }
    }
    
    @Test("커스텀 재시도 가능 상태 코드 설정")
    func customRetryableStatusCodes() async throws {
        let retrier = DefaultRequestRetrier(
            retryableStatusCodes: [401, 403]
        )
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        
        // 커스텀 코드는 재시도
        let error1 = NetworkError.invalidStatusCode(401)
        let result1 = try await retrier.retry(request, dueTo: error1, retryCount: 0)
        if case .retryWithDelay = result1 {
            // 성공
        } else {
            Issue.record("Expected retryWithDelay for 401, got \(result1)")
        }
        
        // 기본 코드는 재시도 안 함
        let error2 = NetworkError.invalidStatusCode(500)
        let result2 = try await retrier.retry(request, dueTo: error2, retryCount: 0)
        switch result2 {
        case .doNotRetry:
            #expect(true)
        default:
            #expect(false)
        }
    }
    
    @Test("커스텀 지연 시간 설정")
    func customRetryDelay() async throws {
        let retrier = DefaultRequestRetrier(retryDelay: 2.5)
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let error = NetworkError.invalidStatusCode(500)
        
        let result = try await retrier.retry(request, dueTo: error, retryCount: 0)
        
        if case .retryWithDelay(let delay) = result {
            #expect(delay == 2.5)
        } else {
            Issue.record("Expected retryWithDelay with delay 2.5, got \(result)")
        }
    }
}
