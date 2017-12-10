//
//  ShareController.swift
//  Conjugate
//
//  Created by Halil Gursoy on 09/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit
import RVMP

class ShareController {
    
    let router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func shareApp(sourceView: ViewComponent, sourceRect: CGRect? = nil) {
        let textToShare = "Analyse German text with der Satz. Download for iOS now at "
        let urlStringToShare = "https://itunes.apple.com/app/id1299564210?l=en&mt=8"
        
        share(text: textToShare, url: urlStringToShare, sourceView: sourceView, sourceRect: sourceRect)
    }
    
    func share(text: String, url: String, sourceView: ViewComponent, sourceRect: CGRect? = nil) {
        let objectToShare = [text, url]
        let activityVC = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)

        router.present(sheetViewController: activityVC, sourceView: sourceView as? UIView, sourceRect: sourceRect)
    }
}
