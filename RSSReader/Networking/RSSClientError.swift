//
//  RSSClientError.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 22.04.2026.
//

import Foundation

enum RSSClientError: Error, LocalizedError {
    case invalidURL
    case noData
    case parsingError
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL адрес"
        case .noData:
            return "Нет данных от сервера"
        case .parsingError:
            return "Ошибка парсинга RSS ленты"
        case .networkError(let message):
            return "Ошибка сети: \(message)"
        }
    }
}
