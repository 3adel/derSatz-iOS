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
        presenter?.getInitialData()
    }
    
    func render(with viewModel: AnalysisViewModel) {
        let sizes: [ViewComponentSize] = viewModel.sentenceInfos.map {
            let height = calculateHeight(for: $0)
            return ViewComponentSize(height: height)
        }
        
        let section = ListSection(viewIdentifier: SentenceView.Identifier,
                                            viewModels: viewModel.sentenceInfos,
                                            sizes: sizes)
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
        popupFrame.origin.y += wordFrame.height + 5
        popupFrame.origin.x += wordFrame.width / 2
        
        let frameDifference = (popupFrame.origin.x + popupFrame.width + 10) - listView.frame.width
        popupFrame.origin.x -= max(frameDifference, 0)
        
        wordDetailView.frame = popupFrame
        
        wordDetailView.moveTriangle(to: wordDetailView.convert(wordFrameInView.origin, from: view).x + wordFrameInView.width / 2)
        
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
    
    private func calculateHeight(for sentenceViewModel: SentenceViewModel) -> CGFloat {
        return  sentenceViewModel.sentence.height(withConstrainedWidth: view.frame.width, font: .boldSystemFont(ofSize: 19)) + sentenceViewModel.translation.height(withConstrainedWidth: view.frame.width, font: .italicSystemFont(ofSize: 17))
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
