//
//  ParameterEncoder.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/6/26.
//

import Foundation

public protocol ParameterEncoder: Sendable {
    func encode<Parameters: Encodable & Sendable>(
        _ parameters: Parameters?,
        into request: URLRequest
    ) throws -> URLRequest
}

public final class JSONParameterEncoder: ParameterEncoder {
    private let encoder: JSONEncoder
    
    public init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }
    
    public func encode<Parameters: Encodable & Sendable>(
        _ parameters: Parameters?,
        into request: URLRequest
    ) throws -> URLRequest {
        guard let parameters else { return request }
        
        var request = request
        
        do {
            let data = try encoder.encode(parameters)
            request.httpBody = data
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue(
                    "application/json",
                    forHTTPHeaderField: "Content-Type"
                )
            }
        } catch {
            throw NetworkError.jsonEncodingFailed(error: error)
        }
        
        return request
    }
}

public struct URLQueryEncoder: ParameterEncoder {
    
    public func encode<Parameters: Encodable & Sendable>(
        _ parameters: Parameters?,
        into request: URLRequest
    ) throws -> URLRequest {

        guard
            let parameters,
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return request
        }

        var request = request
        let data = try JSONEncoder().encode(parameters)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        components.queryItems = json?.map {
            URLQueryItem(name: $0.key, value: "\($0.value)")
        }

        request.url = components.url
        
        return request
    }
}

public struct EmptyEncoder: ParameterEncoder {
    
    public func encode<Parameters: Encodable & Sendable>(
        _ parameters: Parameters?,
        into request: URLRequest
    ) throws -> URLRequest {
        
        return request
    }
}
