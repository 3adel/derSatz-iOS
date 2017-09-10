//
//  RVMPInterface.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP

protocol InputPresenterProtocol: BasePresenter {
    func textInputDidChange(to text: String)
    func didTapAnalyseButton()
}

protocol InputViewProtocol: View {
}

protocol AnalysisPresenterProtocol: BasePresenter {
}

protocol AnalysisViewProtocol: View {
    func render(with viewModel: AnalysisViewModel)
}

protocol AnalysisDetailViewProtocol: View {
}
