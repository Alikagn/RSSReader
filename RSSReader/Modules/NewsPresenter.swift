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
    func showWebView(url: URL)  // ← ДОБАВЬТЕ ЭТОТ МЕТОД
}

protocol NewsPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapRefresh()
    func didSelectNews(at index: Int)
    func getNewsCount() -> Int
    func getNews(at index: Int) -> RSSItem
}

// MARK: - Presenter
final class NewsPresenter: NewsPresenterProtocol {
    
    // MARK: - Dependencies
    private weak var view: NewsViewProtocol?
    private let newsService: NewsServiceProtocol
    
    // MARK: - State
    private var news: [RSSItem] = []
    
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
        let item = news[index]
        
        // Открываем URL через View
        if let url = URL(string: item.link) {
            view?.showWebView(url: url)  // ← Теперь这个方法 существует
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
                    self?.news = news
                    self?.view?.showNews(news)
                    print("✅ Загружено \(news.count) новостей")
                    
                case .failure(let error):
                    self?.view?.showError(error.localizedDescription)
                }
            }
        }
    }
}
