//
//  ContentViewModel.swift
//  URLSessionNetworking
//
//  Created by Junyoung on 1/9/26.
//

import Combine

final class ContentViewModel: ObservableObject {
    @Published var text: String = "Hello, World!"
    let networkClient: NetworkClient
    
    init() {
        networkClient = DefaultNetworkClient(session: .plain)
    }
}
