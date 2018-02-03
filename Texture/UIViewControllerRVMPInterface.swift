//
//  UIViewControllerRVMPInterface.swift
//  Texture
//
//  Created by Halil Gursoy on 31.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import UIKit
import SwiftMessages

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
        let messageView = setUpMessageView(withText: errorMessage, layout: .messageView)
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
