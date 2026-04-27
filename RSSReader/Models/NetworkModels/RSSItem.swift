//
//  RSSItem.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 20.04.2026.
//

import Foundation

struct RSSItem {
    let title: String
    let link: String
    let pubDate: String
    let description: String?
    let guid: String?
    let iconURL: String?
    let enclosureURL: String?
    var isRead: Bool          
    
    // MARK: - Computed Properties
    var formattedIconURL: URL? {
        guard let iconURL = iconURL else { return nil }
        return URL(string: iconURL)
    }
    
    var formattedEnclosureURL: URL? {
        guard let enclosureURL = enclosureURL else { return nil }
        return URL(string: enclosureURL)
    }
}

