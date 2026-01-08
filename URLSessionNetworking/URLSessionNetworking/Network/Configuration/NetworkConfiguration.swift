//
//  NetworkConfiguration.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/6/26.
//

import Foundation

public struct NetworkConfiguration {
    /// BaseURL
    static let baseURL: URL? = {
        return URL(string: "")
    }()
    
    /// 기본 헤더 정보
    public static let defaultHeader: [HTTPHeader] = {
       [
            HTTPHeader(name: "Accept", value: "application/json"),
            HTTPHeader(name: "X-Platform", value: "iOS"),
            HTTPHeader(name: "X-App-Version", value: appVersion)
       ]
    }()
}

extension NetworkConfiguration {
    private static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
}
