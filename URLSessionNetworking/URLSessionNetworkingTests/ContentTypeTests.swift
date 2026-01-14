//
//  ContentTypeTests.swift
//  URLSessionNetworkingTests
//
//  Created by Junyoung on 1/8/26.
//

import Testing
@testable import URLSessionNetworking

struct ContentTypeTests {
    
    @Test("각 ContentType의 rawValue가 올바른지 확인")
    func rawValues() async {
        #expect(ContentType.json.rawValue == "application/json")
        #expect(ContentType.multipart.rawValue == "multipart/form-data")
        #expect(ContentType.formURLEncoded.rawValue == "application/x-www-form-urlencoded")
    }
}
