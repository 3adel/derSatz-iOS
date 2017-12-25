//
//  SentenceDataSource.swift
//  Texture
//
//  Created by Halil Gursoy on 03.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import ListKit

class SentenceDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var headerViewModel: ArticleImageHeaderViewModel? = nil
    var sentences: [SentenceViewModel] = []
    
    var onWordTap: ((IndexPath) -> Void)?
    var onScroll: (() -> Void)?
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SentenceView.Identifier, for: indexPath) as? SentenceView else { return UICollectionViewCell() }

        cell.update(with: sentences[indexPath.item], width: collectionView.frame.width)

        let didTapWordCallback: UserActionCallback = { [weak self] _, wordIndexPath in
            guard let indexPath = wordIndexPath as? IndexPath else { return }
            self?.onWordTap?(indexPath)
        }
        cell.register(action: SentenceAction.didTapWord, callback: didTapWordCallback)
        cell.tag = indexPath.item

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sentences.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = SentenceView.calculateHeight(for: sentences[indexPath.item], inWidth: width)
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let headerViewModel = headerViewModel else { return .zero }
        
        let height: CGFloat = headerViewModel.imageURL != nil ? 211 : 0
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ArticleImageHeaderView.Identifier, for: indexPath) as? ArticleImageHeaderView,
        let headerViewModel = headerViewModel
        else { return UICollectionReusableView() }
        
        headerView.update(with: headerViewModel)
        
        return headerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll?()
    }
}
