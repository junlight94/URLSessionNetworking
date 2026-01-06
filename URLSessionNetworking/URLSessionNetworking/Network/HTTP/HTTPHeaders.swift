//
//  HTTPHeaders.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/5/26.
//

import Foundation

public struct HTTPHeaders: Hashable, Sendable {
    private var headers: [HTTPHeader] = []
    
    public init() {}
    
    public init(_ headers: [HTTPHeader]) {
        headers.forEach { update($0) }
    }
    
    public init(_ dictionary: [String: String]) {
        dictionary.forEach { update(HTTPHeader(name: $0.key, value: $0.value)) }
    }
}

extension HTTPHeaders {
    /// `name`과 `value`를 사용하여 대소문자를 구분하지 않고 인스턴스에 `HTTPHeader`를 업데이트하거나, 존재하지 않으면 추가합니다.
    ///
    /// - Parameters:
    ///   - name:  `HTTPHeader` name.
    ///   - value: `HTTPHeader` value.
    public mutating func add(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }
    
    /// 전달된 `HTTPHeader`를 대소문자를 구분하지 않고 인스턴스에 업데이트하거나, 존재하지 않으면 추가합니다.
    ///
    ///
    /// - Parameter header: `HTTPHeader` 업데이트 혹은 추가
    public mutating func add(_ header: HTTPHeader) {
        update(header)
    }
    
    /// `name`과 `value`를 사용하여 대소문자를 구분하지 않고 인스턴스에 `HTTPHeader`를 업데이트하거나, 존재하지 않으면 추가합니다.
    ///
    /// - Parameters:
    ///   - name:  `HTTPHeader` name.
    ///   - value: `HTTPHeader` value.
    public mutating func update(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }
    
    /// 전달된 `HTTPHeader`를 대소문자를 구분하지 않고 인스턴스에 업데이트하거나, 존재하지 않으면 추가합니다.
    ///
    /// - Parameter header: `HTTPHeader` 업데이트 혹은 추가
    public mutating func update(_ header: HTTPHeader) {
        // 해당 인덱스에 name이 없으면 append
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }
        
        // 헤더의 value 교체
        headers.replaceSubrange(index...index, with: [header])
    }
    
    /// 제공된 이름을 기준으로 대소문자를 구분하지 않고 인스턴스에 존재하는 `HTTPHeader`를 제거합니다.
    ///
    /// - Parameter name: 제거할 `HTTPHeader`의 `name`
    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }
        
        headers.remove(at: index)
    }
}

extension [HTTPHeader] {
    /// 전달받은 name과 대소문자를 구분하지 않고 일치하는 HTTPHeader가 있다면 그 인덱스를 반환
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}
