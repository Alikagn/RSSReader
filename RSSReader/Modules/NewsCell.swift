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
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .systemGray6
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
    
    // MARK: - Синяя точка для непрочитанных сообщений
    private let unreadDot: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 6  // ← Радиус 6 = диаметр 12 (как в iMessage)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
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
        contentView.addSubview(iconImageView)
        contentView.addSubview(unreadDot)      // ← Добавляем точку
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            // Иконка слева
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Синяя точка (слева от текста, как в iMessage)
            unreadDot.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            unreadDot.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            unreadDot.widthAnchor.constraint(equalToConstant: 12),
            unreadDot.heightAnchor.constraint(equalToConstant: 12),
            
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: unreadDot.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Дата
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: unreadDot.trailingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with item: RSSItem) {
        titleLabel.text = item.title
        dateLabel.text = formatDate(item.pubDate)
        
        // Показываем или скрываем синюю точку в зависимости от статуса прочтения
        unreadDot.isHidden = item.isRead
        
        // Если новость не прочитана - делаем заголовок жирным
        if item.isRead {
            titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
            titleLabel.textColor = .secondaryLabel
        } else {
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            titleLabel.textColor = .label
        }
        
        // Загружаем иконку
        if let enclosureURL = item.formattedEnclosureURL {
            loadImage(from: enclosureURL)
        } else if let iconURL = item.formattedIconURL {
            loadImage(from: iconURL)
        } else {
            iconImageView.image = UIImage(systemName: "newspaper")
            iconImageView.tintColor = .systemBlue
        }
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
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.iconImageView.image = image
            }
        }.resume()
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
        iconImageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        unreadDot.isHidden = true
    }
}
