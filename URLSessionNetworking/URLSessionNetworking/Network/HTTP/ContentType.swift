//
//  ContentType.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/5/26.
//

import Foundation

public enum ContentType: String {
    case json = "application/json"
    case multipart = "multipart/form-data"
    case formURLEncoded = "application/x-www-form-urlencoded"
}
