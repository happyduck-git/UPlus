//
//  BaseMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit
import Combine
import Nuke

protocol BaseMissionViewControllerDelegate: AnyObject {
    func redeemDidTap(vc: BaseMissionViewController)
}

class BaseMissionViewController: UIViewController {

    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Dependency
    private var baseVM: MissionBaseModel?
    
    // MARK: - Delegate
    weak var delegate: BaseMissionViewControllerDelegate?
    
    // MARK: - UI Elements
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .large
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.eventBackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.quizMission
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let quizImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.backgroundColor = .clear
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let weblinkButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.titleLabel?.lineBreakMode = .byTruncatingMiddle
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let quizContainer: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let answerInfoLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.clipsToBounds = true
        label.layer.cornerRadius = 8.0
        label.text = MissionConstants.reselect
        label.textAlignment = .center
        label.textColor = UPlusColor.orange01
        label.backgroundColor = UPlusColor.orange02
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var checkAnswerButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.checkAnswer, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.backgroundColor = .systemGray
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UPlusColor.grayBackground
        self.setUI()
        self.setLayout()
        
        self.configure()
        self.bind()
    }

}

//MARK: - Configure
extension BaseMissionViewController {
    private func configure() {
        guard let vm = self.baseVM else { return }
        self.titleLabel.text = vm.mission.missionContentTitle
        
        if let html = vm.mission.missionContentText,
           let attributedString = vm.retrieveHtmlString(html: html) {
            self.weblinkButton.isHidden = false
            weblinkButton.setAttributedTitle(attributedString, for: .normal)
        }

    }
}

//MARK: - Bind
extension BaseMissionViewController {
    private func bind() {
        guard let vm = self.baseVM else { return }
        
        func bindViewToViewModel() {
            self.weblinkButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink {
                    if let html = vm.mission.missionContentText {
                        vm.openURL(from: html)
                    }
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            vm.$imageUrls
                .receive(on: DispatchQueue.main)
                .sink { [weak self] urls in
                    guard let `self` = self,
                          let url = urls.first else { return }
                    self.spinner.startAnimating()
                    
                    Task {
                        do {
                            self.quizImageView.image = try await ImagePipeline.shared.image(for: url)
                            self.spinner.stopAnimating()
                        }
                        catch {
                            print("Error")
                        }
                    }
                  
                    
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }

}

//MARK: - Set UI & Layout
extension BaseMissionViewController {
    func setBaseVM(vm: MissionBaseModel) {
        self.baseVM = vm
    }
    
    private func setUI() {
        self.view.addSubviews(self.backgroundImageView,
                              self.titleLabel,
                              self.spinner,
                              self.quizImageView,
                              self.weblinkButton,
                              self.quizContainer,
                              self.answerInfoLabel,
                              self.checkAnswerButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.backgroundImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 1),
            
            self.quizImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 3),
            self.quizImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 2),
            self.quizImageView.heightAnchor.constraint(equalToConstant: 200),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizImageView.trailingAnchor, multiplier: 2),
            
            self.spinner.centerXAnchor.constraint(equalTo: self.quizImageView.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.quizImageView.centerYAnchor),
            
            self.weblinkButton.topAnchor.constraint(equalTo: self.quizImageView.bottomAnchor),
            self.weblinkButton.leadingAnchor.constraint(equalTo: self.quizImageView.leadingAnchor),
            self.weblinkButton.trailingAnchor.constraint(equalTo: self.quizImageView.trailingAnchor),
            
            self.quizContainer.topAnchor.constraint(equalTo: self.weblinkButton.bottomAnchor),
            self.quizContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.quizContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            self.answerInfoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.bottomAnchor, multiplier: 3),
            self.answerInfoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.answerInfoLabel.widthAnchor.constraint(equalToConstant: 135),
            self.answerInfoLabel.heightAnchor.constraint(equalToConstant: 30),
            
            self.checkAnswerButton.topAnchor.constraint(equalToSystemSpacingBelow: self.answerInfoLabel.bottomAnchor, multiplier: 2),
            self.checkAnswerButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.checkAnswerButton.trailingAnchor, multiplier: 5),
            self.checkAnswerButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.checkAnswerButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
        
        self.quizImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.weblinkButton.setContentHuggingPriority(.defaultHigh, for: .vertical)

    }

}
