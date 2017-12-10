//
//  Article.swift
//  Texture
//
//  Created by Halil Gursoy on 02.10.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

struct Article: Codable {
    enum Source: String, Codable {
        case freeText
        case internet
    }
    
    var title: String
    var url: URL?
    var topImageURL: URL?
    var summary: String
    var body: String
    var source: Source
    
    init(freeText: String) {
        self.init(title: "", url: nil, topImageURL: nil, summary: "", body: freeText, source: .freeText)
    }
    
    init(title: String, url: URL?, topImageURL: URL?, summary: String, body: String, source: Source = .internet) {
        self.title = title
        self.url = url
        self.topImageURL = topImageURL
        self.summary = summary
        self.body = body
        self.source = source
    }
}
