//
//  DefaultNetworkClient.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/6/26.
//

import Foundation

public final class DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    public func send<R: Request>(with request: R) async throws -> R.Response {
        let urlRequest = request.asRequest()
        
        let (data, urlResponse) = try await session.data(for: urlRequest)
        let decoded: R.Response = try handleResponse(data: data, response: urlResponse)
        
        return decoded
    }
}

extension DefaultNetworkClient {
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
