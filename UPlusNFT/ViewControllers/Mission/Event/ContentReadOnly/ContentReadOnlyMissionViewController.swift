//
//  ContentReadOnlyMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import Combine

final class ContentReadOnlyMissionViewController: UIViewController {

    //MARK: - Dependency
    private let vm: ContentReadOnlyMissionViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인완료!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    init(vm: ContentReadOnlyMissionViewViewModel) {
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

extension ContentReadOnlyMissionViewController {
    
    private func bind() {
        
        self.vm.$imageUrls
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.label.text = (self.vm.mission.missionContentTitle ?? "Title") + "\n" + "ImagePaths: \($0)"
                
            }
            .store(in: &bindings)

    }
    
}

//MARK: - Set UI & Layout
extension ContentReadOnlyMissionViewController {
    private func setUI() {
        self.view.addSubviews(
            self.label,
            self.submitButton
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.label.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.label.trailingAnchor, multiplier: 2),
            
            self.submitButton.topAnchor.constraint(equalToSystemSpacingBelow: self.label.bottomAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.submitButton.bottomAnchor, multiplier: 2),
            self.submitButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.submitButton.trailingAnchor, multiplier: 5)
        ])
        
        self.submitButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
