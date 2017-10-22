//
//  AnalysisViewController.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import RVMP
import ListKit
import MobileCoreServices

class AnalysisViewController: UIViewController, AnalysisViewProtocol {
    @IBOutlet weak var listView: ListView!
    
    var presenter: BasePresenter?
    var analysisPresenter: AnalysisPresenterProtocol? {
        return presenter as? AnalysisPresenterProtocol
    }
    
    private var loader: UIActivityIndicatorView?
    private var detailPopup: WordDetailPopupView?
    private var closeDetailButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.bounces = true
        listView.onScroll = { [weak self] in
            self?.hideWordDetail()
        }
        
        var hasURL = false
        
        if let extentionItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in extentionItems {
                for provider in item.attachments! as! [NSItemProvider] {
                    guard provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) else { continue }
                    // This is an image. We'll load it, then place it in our image view.
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (url, error) in
                        guard let url = url as? URL else { return }
                        DispatchQueue.main.async { [weak self] in
                            self?.presenter = AnalysisPresenter()
                            self?.presenter?.view = self
                            self?.analysisPresenter?.inputText = url.absoluteString
                            self?.presenter?.getInitialData()
                        }
                    })
                    hasURL = true
                    break
                }
                
                if (hasURL) {
                    // We only handle one image, so stop looking for more.
                    break
                }
            }
        }
        
        if !hasURL { presenter?.getInitialData() }
    }
    
    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    func render(with viewModel: AnalysisViewModel) {
        let section = ListSection(viewIdentifier: SentenceView.Identifier,
                                            viewModels: viewModel.sentenceInfos,
                                            sizes: [DynamicViewComponentSize()])
        section.interitemSpacing = 10
        
        let didTapWordCallback: UserActionCallback = { [weak self] _, wordIndexPath in
            guard let indexPath = wordIndexPath as? IndexPath else { return }
            self?.analysisPresenter?.didTapOnWord(at: indexPath.item, inSentenceAt: indexPath.section)
        }
        let userAction = UserActionCallbackPair(SentenceAction.didTapWord, didTapWordCallback)
        section.cellActionCallbacks.append(userAction)
        
        listView.update(section: section)
    }
    
    func showWordDetailPopup(with viewModel: WordDetailPopupViewModel, forWordAt index: Int, inSentenceAt sentenceIndex: Int) {
        guard let wordDetailView = WordDetailPopupView.from(nibWithName: "WordDetailPopupView") as? WordDetailPopupView,
            let sentenceView = listView.viewForItem(at: IndexPath(item: sentenceIndex, section: 0)) as? SentenceView,
            let wordFrame = sentenceView.frameForWord(at: index) else { return }
        
        wordDetailView.update(with: viewModel)
        
        let wordFrameInList = listView.convert(wordFrame, from: sentenceView)
        let wordFrameInView = view.convert(wordFrameInList, from: listView)
        var popupFrame = wordFrameInView
        popupFrame.size = CGSize(width: 300, height: 160)
        popupFrame.origin.y += wordFrame.height
//        popupFrame.origin.x += wordFrame.width / 2
        
        let xOriginDifference = (popupFrame.origin.x + popupFrame.width + 10) - listView.frame.width
        popupFrame.origin.x -= max(xOriginDifference, 0)
        
        let yOriginDifference = (popupFrame.origin.y + popupFrame.height + 10) - listView.frame.height
        
        if yOriginDifference > 0 {
            let newOffset = CGPoint(x: 0, y: listView.contentOffset.y + yOriginDifference)
            listView.setContentOffset(newOffset, animated: false)
        }
        
        wordDetailView.frame = popupFrame
        
        wordDetailView.moveTriangle(to: wordDetailView.convert(wordFrameInView.origin, from: view).x + wordFrameInView.width / 4)
        
        wordDetailView.alpha = 0
        view.addSubview(wordDetailView)
        
        hideDetailPopup() {
            self.detailPopup = wordDetailView
            UIView.animate(withDuration: 0.3, animations: {
                wordDetailView.alpha = 1
            }) { _ in
                let closeDetailButton = UIButton(type: .custom)
                closeDetailButton.frame = self.view.frame
                closeDetailButton.addTarget(self, action: #selector(self.hideWordDetail), for: .touchUpInside)
                self.view.addSubview(closeDetailButton)

                self.closeDetailButton = closeDetailButton
            }
        }
    }
    
    @objc func hideWordDetail() {
        hideDetailPopup(completion: nil)
    }
    
    private func hideDetailPopup(completion: (()->Void)?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.detailPopup?.alpha = 0
        }) { _ in
            self.detailPopup?.removeFromSuperview()
            completion?()
            self.closeDetailButton?.removeFromSuperview()
        }
    }
}

extension AnalysisViewController {
    override func showLoader() {
        loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loader!)
        loader?.startAnimating()
    }
    
    override func hideLoader() {
        loader?.stopAnimating()
        navigationItem.rightBarButtonItem = nil
        loader = nil
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: font], context: nil)
        
        // TODO: Remove the temp solution to add 20 pts for incorrect calculation of height
        return ceil(boundingBox.height) + 20
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
