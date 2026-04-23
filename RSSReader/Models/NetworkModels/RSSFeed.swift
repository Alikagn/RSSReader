//
//  RSSFeed.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 16.04.2026.
//

import Foundation
/*
struct RSSFeed {
    let id: UUID
    let title: String
    let url: String
    let iconURL: String?
    let category: String?
    let lastUpdated: Date
    var articles: [RSSItem]
}
*/
struct RSSFeed {
    let title: String
    let link: String
    let description: String
    let items: [RSSItem]
}
