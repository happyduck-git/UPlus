//
//  MissionBaseScrollViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/17.
//

import UIKit

class MissionBaseScrollViewController: UIViewController {
    
    //MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let canvasView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = RewardsConstants.empty
        label.textAlignment = .center
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = RewardsConstants.empty
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let checkAnswerButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle(RewardsConstants.empty, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
    }
    
}

extension MissionBaseScrollViewController {
    
    private func setUI() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.canvasView)
        self.canvasView.addSubviews(self.titleLabel,
                                    self.subTitleLabel,
                                    self.containerView,
                                    self.checkAnswerButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
           
            self.canvasView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.canvasView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.canvasView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.canvasView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.canvasView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            
        ])

        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.canvasView.topAnchor, multiplier: 2),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.canvasView.leadingAnchor, multiplier: 1),
            self.canvasView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 1),
            
            self.subTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 2),
            self.subTitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.subTitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            
            self.containerView.topAnchor.constraint(equalToSystemSpacingBelow: self.subTitleLabel.bottomAnchor, multiplier: 2),
            self.containerView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            
            self.checkAnswerButton.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.bottomAnchor, multiplier: 3),
            self.checkAnswerButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.canvasView.leadingAnchor, multiplier: 2),
            self.canvasView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.checkAnswerButton.trailingAnchor, multiplier: 2),
            self.canvasView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.checkAnswerButton.bottomAnchor, multiplier: 3)
        ])
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.subTitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.checkAnswerButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
