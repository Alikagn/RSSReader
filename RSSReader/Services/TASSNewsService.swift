//
//  TASSNewsService.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 22.04.2026.
//

import Foundation

protocol NewsServiceProtocol {
    func fetchNews(completion: @escaping (Result<[RSSItem], RSSClientError>) -> Void)
}

final class TASSNewsService: NewsServiceProtocol {
    
    private let client: RSSClientProtocol
    
    init(client: RSSClientProtocol = RSSClient()) {
        self.client = client
    }
    
    func fetchNews(completion: @escaping (Result<[RSSItem], RSSClientError>) -> Void) {
        client.fetchNews(completion: completion)
    }
}
