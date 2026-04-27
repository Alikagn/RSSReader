//
//  NewsPresenter.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 23.04.2026.
//

import Foundation

// MARK: - Protocols
protocol NewsViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showNews(_ news: [RSSItem])
    func showError(_ message: String)
    func updateRefreshControl(animating: Bool)
    func showWebView(url: URL)
    func updateReadStatus(at index: Int, isRead: Bool)  // ← Добавляем метод обновления статуса
}

protocol NewsPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapRefresh()
    func didSelectNews(at index: Int)
    func getNewsCount() -> Int
    func getNews(at index: Int) -> RSSItem
    func addNewFeed(url: String, title: String) // Новый метод
    func toggleReadStatus(at index: Int)        // Новый метод для свайпа
}


// MARK: - Presenter
final class NewsPresenter: NewsPresenterProtocol {
    
    // MARK: - Dependencies
    private weak var view: NewsViewProtocol?
    private let newsService: NewsServiceProtocol
    
    // MARK: - State
    private var news: [RSSItem] = []
    
    // MARK: - UserDefaults для сохранения статуса прочтения
    private let userDefaults = UserDefaults.standard
    private let readNewsKey = "readNewsURLs"
    
    // MARK: - Initialization
    init(view: NewsViewProtocol, newsService: NewsServiceProtocol = TASSNewsService()) {
        self.view = view
        self.newsService = newsService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        loadNews()
    }
    
    func didTapRefresh() {
        loadNews()
    }
    
    func didSelectNews(at index: Int) {
        guard index < news.count else { return }
        var item = news[index]
        
        // Если новость не прочитана - отмечаем как прочитанную
        if !item.isRead {
            markAsRead(at: index)
        }
        
        // Открываем URL
        if let url = URL(string: item.link) {
            view?.showWebView(url: url)
        }
    }
    
    func getNewsCount() -> Int {
        return news.count
    }
    
    func getNews(at index: Int) -> RSSItem {
        return news[index]
    }
    
    // MARK: - Private Methods
    private func loadNews() {
        view?.showLoading()
        view?.updateRefreshControl(animating: true)
        
        newsService.fetchNews { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                self?.view?.updateRefreshControl(animating: false)
                
                switch result {
                case .success(let news):
                    // Восстанавливаем статус прочтения из UserDefaults
                    let updatedNews = self?.restoreReadStatus(for: news) ?? news
                    self?.news = updatedNews
                    self?.view?.showNews(updatedNews)
                    print("✅ Загружено \(updatedNews.count) новостей")
                    
                case .failure(let error):
                    self?.view?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Read Status Management
    private func markAsRead(at index: Int) {
        guard index < news.count else { return }
        
        // Обновляем статус в массиве
        news[index].isRead = true
        
        // Сохраняем URL прочитанной новости в UserDefaults
        var readURLs = userDefaults.array(forKey: readNewsKey) as? [String] ?? []
        let newsURL = news[index].link
        
        if !readURLs.contains(newsURL) {
            readURLs.append(newsURL)
            userDefaults.set(readURLs, forKey: readNewsKey)
        }
        
        // Обновляем UI
        view?.updateReadStatus(at: index, isRead: true)
    }
    
    private func restoreReadStatus(for news: [RSSItem]) -> [RSSItem] {
        let readURLs = userDefaults.array(forKey: readNewsKey) as? [String] ?? []
        
        var updatedNews = news
        for i in 0..<updatedNews.count {
            if readURLs.contains(updatedNews[i].link) {
                updatedNews[i].isRead = true
            } else {
                updatedNews[i].isRead = false
            }
        }
        
        return updatedNews
    }
    
    func addNewFeed(url: String, title: String) {
           // Временная заглушка. Позже здесь будет код для сохранения ленты.
           view?.showError("Функция добавления ленты в разработке")
           print("Добавлена лента: \(title) (\(url))")
       }

       func toggleReadStatus(at index: Int) {
           guard index < news.count else { return }
           let item = news[index]
           if item.isRead {
               // Здесь нужна логика для отметки "непрочитано"
               view?.showError("Функция изменения статуса в разработке")
           } else {
               markAsRead(at: index)
           }
       }
   }
