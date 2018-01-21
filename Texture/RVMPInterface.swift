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
    func render(with viewModel: AnalysisViewModel)
    func showWordDetailPopup(with viewModel: WordDetailPopupViewModel, forWordAt index: Int, inSentenceAt sentenceIndex: Int)
    func updateWordDetailPopup(with viewModel: WordDetailPopupViewModel)
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

extension UIViewController {
    private var defaultConfig: SwiftMessages.Config {
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.duration = SwiftMessages.Duration.seconds(seconds: 10)
        config.interactiveHide = true
        return config
    }
    
    @objc
    public func show(errorMessage: String) {
        let messageView = setUpMessageView(withText: errorMessage, layout: .statusLine)
        messageView.configureTheme(.error)
        SwiftMessages.show(config: defaultConfig, view: messageView)
        
    }
    
    public func show(infoMessage: String) {
        let messageView = setUpMessageView(withText: infoMessage, layout: .messageView)
        messageView.configureTheme(.info)
        SwiftMessages.show(config: defaultConfig, view: messageView)
    }
    
    private func setUpMessageView(withText text: String, layout: MessageView.Layout) -> MessageView {
        let messageView = MessageView.viewFromNib(layout: layout)
        messageView.configureContent(title: nil, body: text, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "Close") { _ in
            SwiftMessages.hide()
        }
        return messageView
    }
}
