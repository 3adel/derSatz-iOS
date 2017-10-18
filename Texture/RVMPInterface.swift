//
//  RVMPInterface.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP

protocol InputPresenterProtocol: BasePresenter {
    func textInputDidChange(to text: String)
    func didTapAnalyseButton()
}

protocol InputViewProtocol: View {
}

protocol AnalysisPresenterProtocol: BasePresenter {
    var inputText: String? { get set }
    func didTapOnWord(at index: Int, inSentenceAt sentenceIndex: Int)
}

protocol AnalysisViewProtocol: View {
    func render(with viewModel: AnalysisViewModel)
    func showWordDetailPopup(with viewModel: WordDetailPopupViewModel, forWordAt index: Int, inSentenceAt sentenceIndex: Int)
}

protocol AnalysisDetailViewProtocol: View {
}
