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
    var source: SourceViewModel?
    
    var onWordTap: ((IndexPath) -> Void)?
    var onScroll: (() -> Void)?
    var onSourceTap: (() -> Void)?
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: return makeSentenceCell(at: indexPath, in: collectionView)
        case 1: return makeSourceCell(at: indexPath, in: collectionView)
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return sentences.count
        case 1: return 1
        default: return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return source != nil ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.section {
        case 0:
            let width = collectionView.frame.width
            let height = SentenceView.calculateHeight(for: sentences[indexPath.item], inWidth: width)
            
            return CGSize(width: width, height: height)
        case 1:
            let width = collectionView.frame.width
            let height =  source?.urlString.height(withConstrainedWidth: width, font: .systemFont(ofSize: 13)) ?? 30
            return CGSize(width: width, height: height + 15)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let headerViewModel = headerViewModel, section == 0 else { return .zero }
        
        let height: CGFloat = headerViewModel.imageURL != nil ? 211 : 0
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ArticleImageHeaderView.Identifier, for: indexPath) as? ArticleImageHeaderView,
        let headerViewModel = headerViewModel,
        indexPath.section == 0
        else { return UICollectionReusableView() }
        
        headerView.update(with: headerViewModel)
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        onSourceTap?()
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll?()
    }
    
    private func makeSentenceCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
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
    
    private func makeSourceCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SourceCell.Identifier, for: indexPath) as? SourceCell,
        let viewModel = source else { return UICollectionViewCell() }
        
        cell.update(with: viewModel)
        
        return cell
    }
}
