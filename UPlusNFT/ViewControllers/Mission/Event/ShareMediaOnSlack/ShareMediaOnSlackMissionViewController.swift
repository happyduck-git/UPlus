//
//  ShareMediaOnSlackMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//
import UIKit
import Combine

final class ShareMediaOnSlackMissionViewController: BaseMissionViewController {

    //MARK: - Dependency
    private let vm: ShareMediaOnSlackMissionViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements

    //MARK: - Init
    init(vm: ShareMediaOnSlackMissionViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.bind()
    }

}

extension ShareMediaOnSlackMissionViewController {
    
    private func bind() {
       
        self.checkAnswerButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                let vc = EventCompletedViewController(vm: self.vm)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            }
            .store(in: &bindings)

    }
    
}

//MARK: - Set UI & Layout
extension ShareMediaOnSlackMissionViewController {
    private func setUI() {
       
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
           
        ])
        
    }
}

extension ShareMediaOnSlackMissionViewController: EventCompletedViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}
