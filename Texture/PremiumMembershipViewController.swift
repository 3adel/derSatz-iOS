//
//  PremiumMembershipViewController.swift
//  Texture
//
//  Created by Halil Gursoy on 28.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import UIKit
import RVMP

struct PremiumMembershipViewModel {
    let title: String
    let body: NSAttributedString
    let buyButtonTitle: String
}

protocol PremiumMembershipPresenterProtocol: BasePresenter {
    func didTapBuyButton()
    func didTapRestorePurchaseButton()
}

protocol PremiumMembershipViewProtocol: View {
    func render(with viewModel: PremiumMembershipViewModel)
}

class PremiumMembershipViewController: UIViewController {
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var buyButton: UIButton!
    @IBOutlet private var restorePurchaseButton: UIButton!
    
    var presenter: BasePresenter?
    var premiumMembershipPresenter: PremiumMembershipPresenterProtocol! {
        return presenter as! PremiumMembershipPresenterProtocol
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.getInitialData()
    }
    
    @IBAction
    func didTapBuyButton(_ control: UIControl) {
        premiumMembershipPresenter.didTapBuyButton()
    }
    
    @IBAction
    func didTapCloseButton(_ control: UIControl) {
        parent?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction
    func didTapRestorePurchaseButton(_ control: UIControl) {
        premiumMembershipPresenter.didTapRestorePurchaseButton()
    }
    
    private func setupUI() {
        headerView.backgroundColor = ThemeService().tintColor
        buyButton.backgroundColor = ThemeService().ctaButtonColor
        
        textView.contentInset = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
        
        buyButton.layer.cornerRadius = 6
    }
}

extension PremiumMembershipViewController: PremiumMembershipViewProtocol {
    func render(with viewModel: PremiumMembershipViewModel) {
        titleLabel.text = viewModel.title
        
        var bodyText = NSMutableAttributedString(string: "")
        
        let image = UIImage(named: "premium")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        
        var imageText = NSAttributedString(attachment: imageAttachment)
        var centeredImageText = NSMutableAttributedString(attributedString: imageText)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        centeredImageText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: imageText.length))
        
        bodyText.append(centeredImageText)
        
        let lineBreak = NSAttributedString.init(string: "\n\n")
        bodyText.append(lineBreak)
        
        bodyText.append(viewModel.body)
        bodyText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: NSRange(location: 0, length: bodyText.length))

        textView.attributedText = bodyText
        
        buyButton.setTitle(viewModel.buyButtonTitle, for: .normal)
    }
}
