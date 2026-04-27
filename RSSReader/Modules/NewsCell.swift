//
//  NewsCell.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 22.04.2026.
//

import UIKit

final class NewsCell: UITableViewCell {
    static let identifier = "NewsCell"
    
    // MARK: - UI Components
    private let feedIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let feedTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Синяя точка для непрочитанных сообщений
    private let unreadDot: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // Кэш для иконок лент
    private static var iconCache: [String: UIImage] = [:]
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(feedIconImageView)
        contentView.addSubview(unreadDot)
        contentView.addSubview(feedTitleLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            // Иконка ленты слева
            feedIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            feedIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            feedIconImageView.widthAnchor.constraint(equalToConstant: 40),
            feedIconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Синяя точка
            unreadDot.leadingAnchor.constraint(equalTo: feedIconImageView.trailingAnchor, constant: 12),
            unreadDot.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            unreadDot.widthAnchor.constraint(equalToConstant: 12),
            unreadDot.heightAnchor.constraint(equalToConstant: 12),
            
            // Название ленты
            feedTitleLabel.leadingAnchor.constraint(equalTo: unreadDot.trailingAnchor, constant: 8),
            feedTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            feedTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Заголовок
            titleLabel.leadingAnchor.constraint(equalTo: feedIconImageView.trailingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: feedTitleLabel.bottomAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Дата
            dateLabel.leadingAnchor.constraint(equalTo: feedIconImageView.trailingAnchor, constant: 20),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with item: RSSItem, feedTitle: String = "ТАСС", feedIconURL: String? = nil) {
        titleLabel.text = item.title
        dateLabel.text = formatDate(item.pubDate)
        feedTitleLabel.text = feedTitle
        
        // Показываем или скрываем синюю точку
        unreadDot.isHidden = item.isRead
        
        // Стиль заголовка в зависимости от прочтения
        if item.isRead {
            titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
            titleLabel.textColor = .secondaryLabel
        } else {
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            titleLabel.textColor = .label
        }
        
        // Загружаем логотип ленты (favicon)
        loadFeedIcon(feedIconURL: feedIconURL, feedTitle: feedTitle)
    }
    
    private func loadFeedIcon(feedIconURL: String?, feedTitle: String) {
        // Проверяем кэш
        let cacheKey = feedIconURL ?? feedTitle
        if let cachedImage = NewsCell.iconCache[cacheKey] {
            feedIconImageView.image = cachedImage
            feedIconImageView.backgroundColor = .clear
            return
        }
        
        // Получаем favicon
        let faviconURLString = getFaviconURL(from: feedIconURL, feedTitle: feedTitle)
        
        guard let url = URL(string: faviconURLString) else {
            setPlaceholderIcon(feedTitle: feedTitle)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.setPlaceholderIcon(feedTitle: feedTitle)
                }
                return
            }
            
            DispatchQueue.main.async {
                NewsCell.iconCache[cacheKey] = image
                self?.feedIconImageView.image = image
                self?.feedIconImageView.backgroundColor = .clear
            }
        }.resume()
    }
    
    private func getFaviconURL(from iconURL: String?, feedTitle: String) -> String {
        // Если есть прямой URL иконки
        if let iconURL = iconURL, !iconURL.isEmpty {
            return iconURL
        }
        
        // Для ТАСС используем прямой URL
        if feedTitle == "ТАСС" {
            return "https://tass.ru/favicon.ico"
        }
        
        // Для других лент формируем URL на основе названия
        let domain = feedTitle.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
        return "https://\(domain).ru/favicon.ico"
    }
    
    private func setPlaceholderIcon(feedTitle: String) {
        // Создаем плейсхолдер с первой буквой
        feedIconImageView.backgroundColor = .systemGray5
        feedIconImageView.image = nil
        
        // Удаляем старые subviews
        feedIconImageView.subviews.forEach { $0.removeFromSuperview() }
        
        let firstLetter = String(feedTitle.prefix(1)).uppercased()
        let label = UILabel()
        label.text = firstLetter
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        feedIconImageView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: feedIconImageView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: feedIconImageView.centerYAnchor)
        ])
    }
    
    // Обновление статуса прочтения (без пересоздания всей ячейки)
    func updateReadStatus(_ isRead: Bool) {
        unreadDot.isHidden = isRead
        
        if isRead {
            titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
            titleLabel.textColor = .secondaryLabel
        } else {
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            titleLabel.textColor = .label
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        
        if let date = formatter.date(from: dateString) {
            let calendar = Calendar.current
            
            if calendar.isDateInToday(date) {
                formatter.dateFormat = "HH:mm"
                return "Сегодня в " + formatter.string(from: date)
            } else if calendar.isDateInYesterday(date) {
                return "Вчера"
            } else {
                formatter.dateFormat = "dd MMM yyyy"
                formatter.locale = Locale(identifier: "ru_RU")
                return formatter.string(from: date)
            }
        }
        
        return dateString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedIconImageView.image = nil
        feedIconImageView.backgroundColor = .systemGray5
        feedIconImageView.subviews.forEach { $0.removeFromSuperview() }
        titleLabel.text = nil
        dateLabel.text = nil
        feedTitleLabel.text = nil
        unreadDot.isHidden = true
    }
}
