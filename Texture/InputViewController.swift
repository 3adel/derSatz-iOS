//
//  ViewController.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import RVMP

class InputViewController: UIViewController, InputViewProtocol {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var analyseButton: UIButton!
    
    var presenter: BasePresenter?
    
    var inputPresenter: InputPresenterProtocol? {
        return presenter as? InputPresenterProtocol
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        textView.placeholder = "Write or paste something here to analyze the text "
        textView.layer.borderColor = UIColor(white: 229/255, alpha: 1.0).cgColor
        textView.layer.borderWidth = 1
        textView.delegate = self
        
        analyseButton.addTarget(self, action: #selector(onTapAnalyseButton), for: .touchUpInside)
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tapRec)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func onTapAnalyseButton() {
        inputPresenter?.didTapAnalyseButton()
    }
    
    @objc
    func closeKeyboard() {
        view.endEditing(true)
    }
}

extension InputViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        inputPresenter?.textInputDidChange(to: textView.text)
    }
    
    
}

