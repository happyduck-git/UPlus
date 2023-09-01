//
//  MissionBaseScrollViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/17.
//

import UIKit
import Nuke
import Combine

protocol BaseMissionScrollViewControllerDelegate: AnyObject {
    func redeemDidTap(vc: BaseMissionScrollViewController)
}

class BaseMissionScrollViewController: UIViewController {
    
    // MARK: - Dependency
    private var baseVM: MissionBaseModel?
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Delegate
    weak var delegate: BaseMissionScrollViewControllerDelegate?
    
    //MARK: - UI Elements
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .large
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let canvasView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.eventBackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let checkAnswerButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = UPlusColor.mint03
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        button.setTitle(RewardsConstants.empty, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.scrollView.showsVerticalScrollIndicator = false
        
        self.setUI()
        self.setLayout()

        self.configure()
    }
    
}

extension BaseMissionScrollViewController {
    func setBaseVM(vm: MissionBaseModel) {
        self.baseVM = vm
        self.bind()
    }
}

//MARK: - Configure
extension BaseMissionScrollViewController {
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
extension BaseMissionScrollViewController {
    
    private func bind() {
        guard let vm = self.baseVM else { return }
        
        func bindViewToViewModel() {
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
        }
        
        func bindViewModelToView() {
            if !(vm.mission.missionSubFormatType == MissionSubFormatType.contentReadOnly.rawValue) {
                vm.$imageUrls
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] urls in
                        guard let `self` = self else { return }
                        
                        if urls.count > 1 {
                            vm.photoAuthFirstImageUrl = urls.first
                            vm.photoAuthSecondImageUrl = urls.last
                            
                        } else {
                            guard let url = urls.first else { return }
                            
                            self.spinner.startAnimating()
                            print("URls: \(urls)")
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
                        
                    }
                    .store(in: &bindings)
            }
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }

}

// MARK: - Set UI & Layout
extension BaseMissionScrollViewController {
    
    private func setUI() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.canvasView)
        self.canvasView.addSubviews(self.backgroundImageView,
                                    self.titleLabel,
                                    self.spinner,
                                    self.quizImageView,
                                    self.weblinkButton,
                                    self.quizContainer,
                                    self.checkAnswerButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
           
            self.canvasView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.canvasView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.canvasView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.canvasView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.canvasView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            
        ])

        NSLayoutConstraint.activate([
            self.backgroundImageView.topAnchor.constraint(equalTo: self.canvasView.topAnchor),
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.canvasView.topAnchor, multiplier: 2),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.canvasView.leadingAnchor, multiplier: 1),
            self.canvasView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 1),

            self.quizImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 2),
            self.quizImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 2),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizImageView.trailingAnchor, multiplier: 2),
            
            self.spinner.centerXAnchor.constraint(equalTo: self.quizImageView.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.quizImageView.centerYAnchor),
            
            self.weblinkButton.topAnchor.constraint(equalTo: self.quizImageView.bottomAnchor),
            self.weblinkButton.leadingAnchor.constraint(equalTo: self.quizImageView.leadingAnchor),
            self.weblinkButton.trailingAnchor.constraint(equalTo: self.quizImageView.trailingAnchor),
            
            self.quizContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.weblinkButton.bottomAnchor, multiplier: 2),
            self.quizContainer.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.quizContainer.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            self.checkAnswerButton.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.bottomAnchor, multiplier: 3),
        

            self.checkAnswerButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.canvasView.leadingAnchor, multiplier: 2),
            self.canvasView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.checkAnswerButton.trailingAnchor, multiplier: 2),
            self.canvasView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.checkAnswerButton.bottomAnchor, multiplier: 3),
            self.checkAnswerButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight)
        ])
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        self.checkAnswerButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
