//
//  AnalysisViewModel.swift
//  Texture
//
//  Created by Halil Gursoy on 26.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

struct AnalysisViewModel {
    let text: String
    let sentenceInfos: [SentenceViewModel]
    let headerViewModel: ArticleImageHeaderViewModel?
}

struct ArticleImageHeaderViewModel {
    let title: String
    let imageURL: URL?
}
