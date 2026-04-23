//
//  NetworkError.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 20.04.2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noInternetConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case noData
    case decodingFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL адрес"
        case .noInternetConnection:
            return "Отсутствует подключение к интернету"
        case .timeout:
            return "Превышено время ожидания"
        case .serverError(let statusCode):
            return "Ошибка сервера: \(statusCode)"
        case .invalidResponse:
            return "Некорректный ответ сервера"
        case .noData:
            return "Сервер не вернул данные"
        case .decodingFailed:
            return "Ошибка обработки данных"
        case .unknown(let error):
            return "Неизвестная ошибка: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Проверьте подключение к интернету"
        case .timeout:
            return "Попробуйте повторить запрос позже"
        case .serverError:
            return "Сервер временно недоступен. Попробуйте позже"
        default:
            return "Попробуйте повторить операцию"
        }
    }
}
