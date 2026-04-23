//
//  RSSClient.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 22.04.2026.
//

import Foundation

protocol RSSClientProtocol {
    func fetchNews(completion: @escaping (Result<[RSSItem], RSSClientError>) -> Void)
}

final class RSSClient: RSSClientProtocol {
    
    // MARK: - Dependencies
    private let session: URLSession
    private let parser: RSSParser
    
    // MARK: - Constants
    private let tassRSSURL = "https://tass.ru/rss/v2.xml"
    
    // MARK: - Initialization
    init(session: URLSession = .shared, parser: RSSParser = RSSParser()) {
        self.session = session
        self.parser = parser
    }
    
    // MARK: - Public Methods
    func fetchNews(completion: @escaping (Result<[RSSItem], RSSClientError>) -> Void) {
        // 1. Создаем URL
        guard let url = URL(string: tassRSSURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 2. Создаем запрос
        let request = buildRequest(url: url)
        
        // 3. Выполняем запрос
        performRequest(request, completion: completion)
    }
    
    // MARK: - Private Methods
    private func buildRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/xml", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15.0
        return request
    }
    
    private func performRequest(_ request: URLRequest,
                                completion: @escaping (Result<[RSSItem], RSSClientError>) -> Void) {
        print("📡 Загрузка RSS ленты: \(request.url?.absoluteString ?? "")")
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    private func handleResponse(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                completion: @escaping (Result<[RSSItem], RSSClientError>) -> Void) {
        
        // 1. Обработка ошибки сети
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(.networkError(error.localizedDescription)))
            }
            return
        }
        
        // 2. Проверка наличия данных
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(.noData))
            }
            return
        }
        
        // 3. Проверка HTTP статуса
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            guard 200...299 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(.networkError("HTTP \(httpResponse.statusCode)")))
                }
                return
            }
        }
        
        // 4. Парсинг XML
        parseXMLData(data, completion: completion)
    }
    
    private func parseXMLData(_ data: Data,
                              completion: @escaping (Result<[RSSItem], RSSClientError>) -> Void) {
        
        let delegate = RSSParserDelegateHandler { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        parser.parse(data: data, delegate: delegate)
    }
}

// MARK: - RSSParserDelegate Handler
private class RSSParserDelegateHandler: NSObject, RSSParserDelegate {
    
    private let completion: (Result<[RSSItem], RSSClientError>) -> Void
    
    init(completion: @escaping (Result<[RSSItem], RSSClientError>) -> Void) {
        self.completion = completion
    }
    
    func parserDidFinishParsing(_ items: [RSSItem]) {
        completion(.success(items))
    }
    
    func parserDidFail(with error: Error) {
        completion(.failure(.parsingError))
    }
}
