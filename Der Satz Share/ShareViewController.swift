//
//  ShareViewController.swift
//  Der Satz
//
//  Created by Halil Gursoy on 28.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Result

class ShareViewController: SLComposeServiceViewController {
    let tintColor = UIColor(red: 92/255, green: 146/255, blue: 253/255, alpha: 1.0)
    let textColor = UIColor.white
    
    let dataStore = DataStore()

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        
        let urlTypeIdentifier = kUTTypeURL as String
        
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first as? NSItemProvider,
            itemProvider.hasItemConformingToTypeIdentifier(urlTypeIdentifier as String) else { return }
        
        itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { [weak self] url, error in
            if let shareURL = url as? URL {
                self?.dataStore.getArticle(at: shareURL) { result in
                    switch result {
                    case .success(let article):
                        print("Article title: \(article.title)")
                    default:
                        break
                    }
                }
            }
            self?.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
        })
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.isTranslucent = false
            navigationBar.shadowImage = UIImage()
            navigationBar.tintColor = textColor
            navigationBar.barTintColor = tintColor
            navigationBar.titleTextAttributes = [.foregroundColor: textColor]
        }
    }
}
