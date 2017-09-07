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
    @IBOutlet weak var collectionView: UICollectionView!
    
    var presenter: BasePresenter?
    var analysisPresenter: AnalysisPresenterProtocol? {
        return presenter as? AnalysisPresenterProtocol
    }
    
    private var loader: UIActivityIndicatorView?
    
    private var dataSource: CollectionViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.bounces = true
        
        dataSource = CollectionViewDataSource(collectionView: collectionView)
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
        
        dataSource?.update(sections: [section])
    }
    
    private func calculateHeight(for sentenceViewModel: SentenceViewModel) -> CGFloat {
        return  sentenceViewModel.sentence.height(withConstrainedWidth: view.frame.width, font: .boldSystemFont(ofSize: 17)) + sentenceViewModel.translation.height(withConstrainedWidth: view.frame.width, font: .italicSystemFont(ofSize: 17)) 
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
