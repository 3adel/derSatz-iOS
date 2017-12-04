//
//  Article.swift
//  Texture
//
//  Created by Halil Gursoy on 02.10.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

struct Article: Codable {
    var title: String
    var url: URL?
    var topImageURL: URL?
    var summary: String
    var body: String
}
