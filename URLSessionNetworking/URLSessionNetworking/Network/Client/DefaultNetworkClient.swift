//
//  DefaultNetworkClient.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/6/26.
//

import Foundation

public final class DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    private let interceptor: RequestInterceptor
    
    public init(session: Session) {
        self.session = session.session
        self.interceptor = session.interceptor
    }
    
    public func send<R: Request>(with request: R) async throws -> R.Response {
        let urlRequest = try request.asRequest()
        
        let (data, urlResponse) = try await requestData(urlRequest)
        let decoded: R.Response = try handleResponse(data: data, response: urlResponse)
        
        return decoded
    }
}

extension DefaultNetworkClient {
    /// 요청을 어댑터로 수정 후 전송하고, 실패 시 재시도 로직 수행
    /// - Parameters:
    ///   - originalRequest: 원본 요청
    ///   - retryCount: 현재 재시도 횟수
    /// - Returns: 응답 데이터와 URLResponse
    private func requestData(
        _ originalRequest: URLRequest,
        retryCount: Int = 0
    ) async throws -> (data: Data, urlResponse: URLResponse)  {
        let adaptedRequest = try await interceptor.adapt(originalRequest)

        do {
            let (data, urlResponse) = try await session.data(for: adaptedRequest)
            return (data, urlResponse)
        } catch {
            let decision = try await interceptor.retry(
                adaptedRequest,
                dueTo: error,
                retryCount: retryCount
            )
            
            switch decision {
            case .retry:
                return try await requestData(
                    originalRequest,
                    retryCount: retryCount + 1
                )
                
            case .retryWithDelay(let delay):
                try await Task.sleep(for: .seconds(delay))
                return try await requestData(
                    originalRequest,
                    retryCount: retryCount + 1
                )
                
            case .doNotRetry:
                throw error
                
            case .doNotRetryWithError(let error):
                throw error
            }
        }
    }
    
    /// HTTP 응답을 검증하고 디코딩
    /// - Parameters:
    ///   - data: 응답 데이터
    ///   - response: URLResponse
    /// - Returns: 디코딩된 응답 객체
    func handleResponse<T: Decodable & Sendable>(
        data: Data,
        response: URLResponse
    ) throws -> T {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.parsingError
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidStatusCode(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(T.self, from: data)
            return response
        } catch {
            throw NetworkError.decodingFailure
        }
    }
}
