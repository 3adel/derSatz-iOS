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
    let body: String
    let buyButtonTitle: String
}

protocol PremiumMembershipPresenterProtocol: BasePresenter {
    func didTapBuyButton()
}

protocol PremiumMembershipViewProtocol: BaseView {
    func render(with viewModel: PremiumMembershipViewModel)
}

class PremiumMembershipViewController: UIViewController {
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var buyButton: UIButton!
    
    var presenter: BasePresenter?
    var premiumMembershipPresenter: PremiumMembershipPresenterProtocol! {
        return presenter as! PremiumMembershipPresenterProtocol
    }
    
    var daysLeft: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let demoViewModel = PremiumMembershipViewModel(title: "Premium Feature",
                                                       body: """
You are using one of our premium features! You can continue using it for \(daysLeft) more days.

After that, you can purchase the premium membership and enjoy the following cool features for life:

    •   Saving text or articles
    •   Analyse articles using just the URL
    •   Analyse articles and text directly in Safari using the app extension

""", buyButtonTitle: "Buy now for $7.99")
        render(with: demoViewModel)
    }
    
    @IBAction
    func didTapBuyButton(_ control: UIControl) {
        premiumMembershipPresenter.didTapBuyButton()
    }
    
    @IBAction
    func didTapCloseButton(_ control: UIControl) {
        parent?.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        headerView.backgroundColor = ThemeService().tintColor
        buyButton.backgroundColor = ThemeService().ctaButtonColor
        
        textView.contentInset = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
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
        
        bodyText.append(NSAttributedString(string: viewModel.body))
        bodyText.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: NSRange(location: 0, length: bodyText.length))

        textView.attributedText = bodyText
        
        buyButton.setTitle(viewModel.buyButtonTitle, for: .normal)
    }
}
