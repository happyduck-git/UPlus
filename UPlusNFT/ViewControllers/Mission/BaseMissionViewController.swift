//
//  BaseMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit

class BaseMissionViewController: UIViewController {

    //MARK: - UI Elements
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인완료!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()

    }

}

//MARK: - Set UI & Layout
extension BaseMissionViewController {
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