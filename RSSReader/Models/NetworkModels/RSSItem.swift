//
//  RSSItem.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 20.04.2026.
//

import Foundation
/*
struct RSSItem {
    let id: UUID
    let feedID: UUID
    var title: String
    var link: String
    var description: String?
    var content: String?
    var pubDate: Date
    var imageURL: String?
    var isRead: Bool
    var isFavorite: Bool
}
*/
struct RSSItem {
    let title: String
    let link: String
    let pubDate: String
    let description: String?
    let guid: String?
}
