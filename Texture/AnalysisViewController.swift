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
import MobileCoreServices


class AnalysisViewController: UIViewController, AnalysisViewProtocol {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var navigationBar: UINavigationBar?
    
    var presenter: BasePresenter?
    var analysisPresenter: AnalysisPresenterProtocol? {
        return presenter as? AnalysisPresenterProtocol
    }
    
    private let themeService = ThemeService()
    
    private var loader: UIActivityIndicatorView?
    private var detailPopup: WordDetailPopupView?
    private var closeDetailButton: UIButton?
    private var toggleButton: ToggleButton?
    
    private lazy var saveBarButtonItem: UIBarButtonItem = {
        let button = ToggleButton(frame: .zero)
        button.contentHorizontalAlignment = .right
        
        button.styleForTrue = ButtonStyleModel(imageName: "star_selected")
        button.styleForFalse = ButtonStyleModel(imageName: "star")
        button.onToggle = { [weak self] toggleSet in
            self?.analysisPresenter?.didTapOnSaveToggle(toggleSet: toggleSet)
        }
        
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.setWidth(equalToConstant: 50)
        barButtonItem.customView?.setHeight(equalToConstant: 50)
        
        toggleButton = button
        
        return barButtonItem
    }()
    
    private var dataSource = SentenceDataSource()
    
    var isExtension: Bool { return extensionContext != nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        getItemFromExtensionContext(supportedTypes: [.text, .url]) { [weak self] item in
            guard let item = item else {
                self?.presenter?.getInitialData()
                return
            }
            
            DispatchQueue.main.async {
                let presenter = AnalysisPresenter()
                let router = Router(rootViewController: self)
                presenter.router = router
                
                self?.presenter = presenter
                
                let analysisPresenter = self?.analysisPresenter as? AnalysisPresenter
                analysisPresenter?.view = self
                
                if let text = item as? String {
                    analysisPresenter?.update(inputText: text)
                } else if let url = item as? URL {
                    analysisPresenter?.update(inputURL: url)
                }
                
                self?.presenter?.getInitialData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = navigationController?.navigationBar {
            themeService.setUpDefaultUI(for: navigationBar)
        }
        
        presenter?.viewDidAppear()
    }
    
    func render(with viewModel: AnalysisViewModel) {
        (saveBarButtonItem.customView as? ToggleButton)?.toggleSet = viewModel.isSaved
        dataSource.sentences = viewModel.sentenceInfos
        dataSource.headerViewModel = viewModel.headerViewModel
        dataSource.source = viewModel.source
        collectionView.reloadData()
        
        if !UserDefaults.shared.didUseAnalysisBefore {
            show(infoMessage: "You can tap on colored words to show more details.")
            UserDefaults.shared.didUseAnalysisBefore = true
        }
    }
    
    func showWordDetailPopup(with viewModel: WordDetailPopupViewModel, forWordAt index: Int, inSentenceAt sentenceIndex: Int) {
        guard let wordDetailView = WordDetailPopupView.from(nibWithName: "WordDetailPopupView") as? WordDetailPopupView,
            let sentenceView = collectionView.cellForItem(at: IndexPath(item: sentenceIndex, section: 0)) as? SentenceView,
            let wordFrame = sentenceView.frameForWord(at: index) else { return }
        
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
        
        self.updateWordDetailPopup(popupView: wordDetailView, with: viewModel, showLoader: true)
        
        hideDetailPopup() {
            self.detailPopup = wordDetailView
            UIView.animate(withDuration: 0.3, animations: {
                wordDetailView.alpha = 1
            }) { _ in
                let closeDetailButton = UIButton(type: .custom)
                closeDetailButton.frame = self.view.frame
                closeDetailButton.addTarget(self, action: #selector(self.hideWordDetail), for: .touchUpInside)
                self.view.insertSubview(closeDetailButton, belowSubview: wordDetailView)

                self.closeDetailButton = closeDetailButton
            }
        }
    }
    
    func updateWordDetailPopup(popupView: WordDetailPopupView?, with viewModel: WordDetailPopupViewModel, showLoader: Bool) {
        let popupView = popupView ?? detailPopup
        guard let detailPopup = popupView else { return }
        detailPopup.update(with: viewModel, showLoader: showLoader)
    }
    
    func updateWordDetailPopup(with viewModel: WordDetailPopupViewModel, showLoader: Bool) {
        updateWordDetailPopup(popupView: nil, with: viewModel, showLoader: showLoader)
    }
    
    func updateSaveToggle(_ isEnabled: Bool) {
        toggleButton?.toggleSet = isEnabled
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
        
        dataSource.onSourceTap = { [weak self] in
            self?.analysisPresenter?.didTapOnSource()
        }
        
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        
        let sentenceNib = UINib(nibName: SentenceView.Nib, bundle: .main)
        collectionView.register(sentenceNib, forCellWithReuseIdentifier: SentenceView.Identifier)
        
        let sourceNib = UINib(nibName: SourceCell.Nib, bundle: .main)
        collectionView.register(sourceNib, forCellWithReuseIdentifier: SourceCell.Identifier)
        
        let headerNIB = UINib(nibName: ArticleImageHeaderView.Nib, bundle: .main)
        collectionView.register(headerNIB, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ArticleImageHeaderView.Identifier)
        
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        if let navigationBar = navigationBar {
            navigationItem.leftBarButtonItem = navigationBar.items?.first?.leftBarButtonItem
            navigationBar.popItem(animated: false)
            navigationBar.pushItem(navigationItem, animated: false)
        }
    }
}

extension AnalysisViewController: NVActivityIndicatorViewable {
    override func showLoader() {
        if isExtension {
            let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            view.addSubview(loader)
            loader.centerInSuperview()
            loader.startAnimating()
            self.loader = loader
        } else {
            startAnimating(CGSize(width: 30, height: 30), message: "Analyzing text...")
        }
    }
    
    override func hideLoader() {
        if isExtension {
            loader?.stopAnimating()
            loader?.removeFromSuperview()
        } else {
            stopAnimating()
        }
    }
}
