//
//  RSSParser.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 22.04.2026.
//

import Foundation

protocol RSSParserDelegate: AnyObject {
    func parserDidFinishParsing(_ items: [RSSItem])
    func parserDidFail(with error: Error)
}

final class RSSParser: NSObject {
    
    private weak var delegate: RSSParserDelegate?
    private var currentElement = ""
    private var currentItem: RSSItem?
    private var items: [RSSItem] = []
    
    // Текущие значения для item
    private var currentTitle = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentDescription = ""
    private var currentGuid = ""
    
    func parse(data: Data, delegate: RSSParserDelegate) {
        self.delegate = delegate
        self.reset()
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    private func reset() {
        items = []
        currentTitle = ""
        currentLink = ""
        currentPubDate = ""
        currentDescription = ""
        currentGuid = ""
    }
}

extension RSSParser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            // Сбрасываем значения для нового элемента
            currentTitle = ""
            currentLink = ""
            currentPubDate = ""
            currentDescription = ""
            currentGuid = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else { return }
        
        switch currentElement {
        case "title":
            currentTitle += trimmedString
        case "link":
            currentLink += trimmedString
        case "pubDate":
            currentPubDate += trimmedString
        case "description":
            currentDescription += trimmedString
        case "guid":
            currentGuid += trimmedString
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let item = RSSItem(
                title: currentTitle,
                link: currentLink,
                pubDate: currentPubDate,
                description: currentDescription.isEmpty ? nil : currentDescription,
                guid: currentGuid.isEmpty ? nil : currentGuid
            )
            items.append(item)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.parserDidFinishParsing(items)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        delegate?.parserDidFail(with: parseError)
    }
}
