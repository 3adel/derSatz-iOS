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
import NVActivityIndicatorView

class AnalysisViewController: UIViewController, AnalysisViewProtocol {
    @IBOutlet var collectionView: UICollectionView!
    
    var presenter: BasePresenter?
    var analysisPresenter: AnalysisPresenterProtocol? {
        return presenter as? AnalysisPresenterProtocol
    }
    
    private var loader: UIActivityIndicatorView?
    private var detailPopup: WordDetailPopupView?
    private var closeDetailButton: UIButton?
    
    private var dataSource = SentenceDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        presenter?.getInitialData()
    }
    
    func render(with viewModel: AnalysisViewModel) {
        dataSource.sentences = viewModel.sentenceInfos
        dataSource.headerViewModel = viewModel.headerViewModel
        collectionView.reloadData()
    }
    
    func showWordDetailPopup(with viewModel: WordDetailPopupViewModel, forWordAt index: Int, inSentenceAt sentenceIndex: Int) {
        guard let wordDetailView = WordDetailPopupView.from(nibWithName: "WordDetailPopupView") as? WordDetailPopupView,
            let sentenceView = collectionView.cellForItem(at: IndexPath(item: sentenceIndex, section: 0)) as? SentenceView,
            let wordFrame = sentenceView.frameForWord(at: index) else { return }
        
        wordDetailView.update(with: viewModel)
        
        let wordFrameInList = collectionView.convert(wordFrame, from: sentenceView)
        let wordFrameInView = view.convert(wordFrameInList, from: collectionView)
        var popupFrame = wordFrameInView
        popupFrame.size = CGSize(width: 300, height: 160)
        popupFrame.origin.y += wordFrame.height
        
        let xOriginDifference = (popupFrame.origin.x + popupFrame.width + 10) - collectionView.frame.width
        popupFrame.origin.x -= max(xOriginDifference, 0)
        
        let yOriginDifference = (popupFrame.origin.y + popupFrame.height + 10) - collectionView.frame.height
        
        let trianglePosition: TrianglePosition
        if yOriginDifference > 0 {
            trianglePosition = .down
            popupFrame.origin.y = wordFrameInView.origin.y - popupFrame.height
        } else {
            trianglePosition = .up
        }
        
        wordDetailView.frame = popupFrame
        
        wordDetailView.moveTriangle(to: wordDetailView.convert(wordFrameInView.origin, from: view).x + wordFrameInView.width / 4,
                                    position: trianglePosition)
        
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
    
    private func setupUI() {
        title = "Analysis"
        
        dataSource.onScroll = { [weak self] in
            self?.hideWordDetail()
        }
        
        dataSource.onWordTap = { [weak self] indexPath in
            self?.analysisPresenter?.didTapOnWord(at: indexPath.item, inSentenceAt: indexPath.section)
        }
        
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        
        let sentenceNib = UINib(nibName: SentenceView.Nib, bundle: .main)
        collectionView.register(sentenceNib, forCellWithReuseIdentifier: SentenceView.Identifier)
        
        let headerNIB = UINib(nibName: ArticleImageHeaderView.Nib, bundle: .main)
        collectionView.register(headerNIB, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ArticleImageHeaderView.Identifier)
    }
}

extension AnalysisViewController: NVActivityIndicatorViewable {
    override func showLoader() {
        startAnimating(CGSize(width: 30, height: 30), message: "Analyzing text...")
    }
    
    override func hideLoader() {
        stopAnimating()
    }
}
