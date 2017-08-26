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
    
    private var dataSource: CollectionViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        return 500
        return  sentenceViewModel.sentence.height(withConstrainedWidth: view.frame.width, font: .boldSystemFont(ofSize: 17)) + 150
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
