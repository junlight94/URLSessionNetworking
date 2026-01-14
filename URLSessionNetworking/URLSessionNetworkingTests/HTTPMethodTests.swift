//
//  HTTPMethodTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/14/26.
//

import Testing
@testable import URLSessionNetworking

struct HTTPMethodTests {
    
    @Test("각 HTTP 메서드의 rawValue가 올바른지 확인")
    func rawValues() {
        #expect(HTTPMethod.get.rawValue == "GET")
        #expect(HTTPMethod.post.rawValue == "POST")
        #expect(HTTPMethod.put.rawValue == "PUT")
        #expect(HTTPMethod.delete.rawValue == "DELETE")
        #expect(HTTPMethod.patch.rawValue == "PATCH")
    }
}
