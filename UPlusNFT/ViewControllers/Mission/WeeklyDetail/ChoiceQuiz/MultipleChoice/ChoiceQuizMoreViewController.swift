//
//  ChoiceQuizMoreViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit
import Combine

final class ChoiceQuizMoreViewController: BaseMissionViewController {

    //MARK: - Dependency
    private let vm: ChoiceQuizMoreViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bind()
    }
    
    //MARK: - Init
    init(vm: ChoiceQuizMoreViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChoiceQuizMoreViewController {
    func bind() {
        self.vm.$imageUrls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.label.text = "Captions:\n" + String(describing: self.vm.mission.missionChoiceQuizCaptions) + "\n" + "ImageUrls:\n" + String(describing: $0)
            }.store(in: &bindings)
       
    }
}
