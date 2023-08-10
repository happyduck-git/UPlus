//
//  AnswerQuizSingularViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit

final class AnswerQuizSingularViewController: BaseMissionViewController {

    private let vm: AnswerQuizSingularViewViewModel
    
    //MARK: - Init
    init(vm: AnswerQuizSingularViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bind()
    }

}

extension AnswerQuizSingularViewController {
    private func bind() {
        let quizzes = self.vm.mission.missionAnswerQuizzes
        
        var string: String = "문제:\n"
        
        if !quizzes.isEmpty {
            for i in stride(from: quizzes.startIndex, to: quizzes.endIndex, by: 2) {
                string += "\(quizzes[i])\n"
            }
        }
        self.label.text = string
    }
  
}
