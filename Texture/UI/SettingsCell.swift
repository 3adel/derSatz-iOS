//
//  SettingsCell.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

class SettingsOptionCell: UITableViewCell {
    @IBOutlet private var leftImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var rightActionButton: UIButton!
    
    var onActionButtonTap: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func update(with viewModel: SettingsOptionViewModel) {
        titleLabel.attributedText = viewModel.title
        leftImageView.image = UIImage(named: viewModel.imageName)?.withRenderingMode(.alwaysTemplate)
        leftImageView.tintColor = .gray
        
        if let ctaViewModel = viewModel.cta {
            rightActionButton.isHidden = false
            rightActionButton.setTitle(ctaViewModel.title, for: .normal)
            onActionButtonTap = ctaViewModel.onTap
        } else {
            rightActionButton.isHidden = true
        }
    }
    
    @objc
    func didTapActionButton(_ control: UIControl) {
        onActionButtonTap?()
    }
    
    private func setupUI() {
        rightActionButton.layer.cornerRadius = 4
        rightActionButton.layer.borderColor = ThemeService().tintColor.cgColor
        rightActionButton.layer.borderWidth = 1
        rightActionButton.tintColor = ThemeService().tintColor
        
        rightActionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
}

class SettingsLanguageCell: UITableViewCell {
    @IBOutlet weak var languageImageView: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    func update(with viewModel: SettingsLanguageViewModel) {
        titleLabel.text = viewModel.title
        languageLabel.text = viewModel.languageName
        languageImageView.image = UIImage(named: viewModel.languageImageName)
    }
}
