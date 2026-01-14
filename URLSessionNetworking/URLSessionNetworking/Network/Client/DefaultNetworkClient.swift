//
//  DefaultNetworkClient.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/6/26.
//

import Foundation

public final class DefaultNetworkClient: NetworkClient {
    private let session: Session
    
    public init(session: Session) {
        self.session = session
    }
    
    public func send<R: Request>(with request: R) async throws -> R.Response {
        let urlRequest = try request.asRequest()
        
        let (data, urlResponse) = try await session.requestData(urlRequest)
        let decoded: R.Response = try handleResponse(data: data, response: urlResponse)
        
        return decoded
    }
}

extension DefaultNetworkClient {
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
