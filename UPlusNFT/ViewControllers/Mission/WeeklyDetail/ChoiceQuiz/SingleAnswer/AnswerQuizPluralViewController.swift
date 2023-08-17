//
//  AnswerQuizPluralViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit
import Combine

final class AnswerQuizPluralViewController: BaseMissionViewController {

    private let vm: AnswerQuizPluralViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Init
    init(vm: AnswerQuizPluralViewViewModel) {
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
        
        // TEMP
        self.checkAnswerButton.isUserInteractionEnabled = true
    }

}

extension AnswerQuizPluralViewController {
    private func bind() {
        
        self.checkAnswerButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                let vc = WeeklyMissionCompleteViewController(vm: self.vm)
                vc.delegate = self
                self.show(vc, sender: self)
            }
            .store(in: &bindings)
    }
  
}

extension AnswerQuizPluralViewController: WeeklyMissionCompleteViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}
