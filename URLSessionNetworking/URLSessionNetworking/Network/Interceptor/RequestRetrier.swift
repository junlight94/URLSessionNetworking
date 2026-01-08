//
//  RequestRetrier.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/8/26.
//

import Foundation

/// 재시도 결과를 나타내는 열거형
public enum RetryResult: Sendable {
    /// 즉시 재시도
    case retry
    /// 지정된 시간 지연 후 재시도
    case retryWithDelay(TimeInterval)
    /// 재시도 하지 않음
    case doNotRetry
    /// 에러와 함께 재시도하지 않음 (에러를 전파)
    case doNotRetryWithError(Error)
}

// MARK: - Protocol

public protocol RequestRetrier: Sendable {
    /// 요청 재시도 여부를 결정합니다.
    ///
    /// - Parameters:
    ///   - request: 실패한 요청
    ///   - error: 발생한 에러
    ///   - retryCount: 현재까지의 재시도 횟수 (0부터 시작)
    /// - Returns: 재시도 결과 (`RetryResult`)
    func retry(
        _ request: URLRequest,
        dueTo error: Error,
        retryCount: Int
    ) async throws -> RetryResult
}


// MARK: - Implement

public struct DefaultRequestRetrier: RequestRetrier {

    /// 최대 재시도 횟수
    private let maxRetryCount: Int

    /// 재시도 가능한 HTTP 상태 코드
    private let retryableStatusCodes: Set<Int>

    /// 재시도 지연 시간 (초)
    private let retryDelay: TimeInterval

    public init(
        maxRetryCount: Int = 3,
        retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504],
        retryDelay: TimeInterval = 1.0
    ) {
        self.maxRetryCount = maxRetryCount
        self.retryableStatusCodes = retryableStatusCodes
        self.retryDelay = retryDelay
    }

    public func retry(
        _ request: URLRequest,
        dueTo error: Error,
        retryCount: Int
    ) async throws -> RetryResult {

        // 최대 재시도 횟수 초과
        guard retryCount < maxRetryCount else {
            return .doNotRetry
        }

        // HTTP 상태 코드 기반 재시도 판단
        if case NetworkError.invalidStatusCode(let statusCode) = error,
           retryableStatusCodes.contains(statusCode) {
            return .retryWithDelay(retryDelay)
        }

        return .doNotRetry
    }
}
