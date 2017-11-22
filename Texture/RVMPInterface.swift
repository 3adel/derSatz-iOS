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
}

protocol AnalysisViewProtocol: View {
    func render(with viewModel: AnalysisViewModel)
    func showWordDetailPopup(with viewModel: WordDetailPopupViewModel, forWordAt index: Int, inSentenceAt sentenceIndex: Int)
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

extension UIViewController {
    private var defaultConfig: SwiftMessages.Config {
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        return config
    }
    
    @objc
    public func show(errorMessage: String) {
        let messageView = setUpMessageView(withText: errorMessage)
        messageView.configureTheme(.error)
        SwiftMessages.show(config: defaultConfig, view: messageView)
        
    }
    
    public func show(infoMessage: String) {
        let messageView = setUpMessageView(withText: infoMessage)
        messageView.configureTheme(.info)
        SwiftMessages.show(config: defaultConfig, view: messageView)
    }
    
    private func setUpMessageView(withText text: String) -> MessageView {
        let messageView = MessageView.viewFromNib(layout: .statusLine)
        messageView.configureContent(title: nil, body: text, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        return messageView
    }
}
