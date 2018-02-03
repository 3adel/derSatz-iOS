//
//  RVMPInterface.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP
import SwiftMessages

protocol InputPresenterProtocol: BasePresenter {
    func textInputDidChange(to text: String)
    func didTapAnalyseButton()
}

protocol InputViewProtocol: View {
}

protocol AnalysisPresenterProtocol: BasePresenter {
    func didTapOnWord(at index: Int, inSentenceAt sentenceIndex: Int)
    func didTapOnSaveToggle(toggleSet: Bool)
    func didTapOnSource()
}

protocol AnalysisViewProtocol: View {
    var isExtension: Bool { get }
    func render(with viewModel: AnalysisViewModel)
    func showWordDetailPopup(with viewModel: WordDetailPopupViewModel, forWordAt index: Int, inSentenceAt sentenceIndex: Int)
    func updateWordDetailPopup(with viewModel: WordDetailPopupViewModel, showLoader: Bool)
    func updateSaveToggle(_ isEnabled: Bool)
}

protocol AnalysisDetailViewProtocol: View {
}

protocol SettingsView: View {
    func render(with viewModel: SettingsViewModel)
}

protocol SettingsPresenterType: BasePresenter {
    func getOptions()
    func optionSelected(at section: Int, index: Int, sourceView: ViewComponent, sourceRect: CGRect)
}

protocol HelpPresenterType: BasePresenter {}

protocol HelpView: View {
    func render(with viewModel: HelpViewModel)
}
