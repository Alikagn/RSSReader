//
//  RSSFeed.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 16.04.2026.
//

import Foundation

struct RSSFeed {
    let title: String
    let link: String
    let description: String
    let iconURL: String?
    let items: [RSSItem]
    
    // MARK: - Computed Properties
    var formattedIconURL: URL? {
        guard let iconURL = iconURL else { return nil }
        return URL(string: iconURL)
    }
}
