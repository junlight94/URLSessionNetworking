//
//  Request.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/5/26.
//

import Foundation

public protocol Request {
    associatedtype Response: Decodable & Sendable
    
    var header: [HTTPHeader] { get }
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameter: RequestParameter { get }
    
    func asRequest() -> URLRequest
}

extension Request {
    func asRequest() throws -> URLRequest {
        guard let baseURL = baseURL else {
            throw NetworkError.invalidURL
        }
        
        let url = baseURL.appending(path: path)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}
