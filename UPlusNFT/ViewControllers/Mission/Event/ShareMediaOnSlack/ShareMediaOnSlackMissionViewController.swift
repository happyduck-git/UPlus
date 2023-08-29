//
//  ShareMediaOnSlackMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//
import UIKit
import Combine

final class ShareMediaOnSlackMissionViewController: BaseMissionScrollViewController {

    //MARK: - Dependency
    private let vm: ShareMediaOnSlackMissionViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let step1CardView: IDCardView = {
        let view = IDCardView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 12.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let step2CardView: IDCardView = {
        let view = IDCardView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 12.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textfieldView: SlackShareTextFieldView = {
        let view = SlackShareTextFieldView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 12.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Init
    init(vm: ShareMediaOnSlackMissionViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        
        self.bind()
        
        self.checkAnswerButton.setTitle(MissionConstants.submit, for: .normal)
        
        DispatchQueue.main.async {
            self.step1CardView.playVideo()
        }
        
    }

}

// MARK: - Configure
extension ShareMediaOnSlackMissionViewController {
    
    private func configure() {
        self.step1CardView.configure(cardType: .step1)
        self.step2CardView.configure(cardType: .step2)
        self.textfieldView.configure(with: self.vm)
        
        self.step2CardView.delegate = self
        self.textfieldView.delegate = self
    }
    
}

// MARK: - Bind
extension ShareMediaOnSlackMissionViewController {
    
    private func bind() {
       
        self.checkAnswerButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                var vc: BaseMissionCompletedViewController?
                
                switch self.vm.type {
                case .event:
                    vc = EventCompletedViewController(vm: self.vm)
                    vc?.delegate = self
                case .weekly:
                    vc = WeeklyMissionCompleteViewController(vm: self.vm)
                    vc?.delegate = self
                }
                
                guard let vc = vc else { return }
                self.navigationController?.modalPresentationStyle = .fullScreen
                self.show(vc, sender: self)
                
            }
            .store(in: &bindings)
        
        self.vm.$textFieldText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                
                let bgColor: UIColor = $0.isEmpty ? UPlusColor.gray02 : UPlusColor.mint03
                let textColor: UIColor = $0.isEmpty ? .white : .black
                let interactive: Bool = $0.isEmpty ? false : true
                
                self.checkAnswerButton.backgroundColor = bgColor
                self.checkAnswerButton.setTitleColor(textColor, for: .normal)
                self.checkAnswerButton.isUserInteractionEnabled = interactive
            }
            .store(in: &bindings)
    }
    
}

//MARK: - Set UI & Layout
extension ShareMediaOnSlackMissionViewController {
    private func setUI() {
        
        self.containerView.addSubviews(self.step1CardView,
                                       self.step2CardView,
                                       self.textfieldView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.step1CardView.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.step1CardView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 3),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.step1CardView.trailingAnchor, multiplier: 3),
            
            self.step2CardView.topAnchor.constraint(equalToSystemSpacingBelow: self.step1CardView.bottomAnchor, multiplier: 4),
            self.step2CardView.leadingAnchor.constraint(equalTo: self.step1CardView.leadingAnchor),
            self.step2CardView.trailingAnchor.constraint(equalTo: self.step1CardView.trailingAnchor),
            
            self.textfieldView.topAnchor.constraint(equalToSystemSpacingBelow: self.step2CardView.bottomAnchor, multiplier: 4),
            self.textfieldView.leadingAnchor.constraint(equalTo: self.step1CardView.leadingAnchor),
            self.textfieldView.trailingAnchor.constraint(equalTo: self.step1CardView.trailingAnchor),
            self.textfieldView.heightAnchor.constraint(equalToConstant: 200),
            
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.textfieldView.bottomAnchor, multiplier: 2)
        ])
        
    }
    
    private func setDelegate() {
        self.step2CardView.delegate = self
    }
}

extension ShareMediaOnSlackMissionViewController: BaseMissionCompletedViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}

extension ShareMediaOnSlackMissionViewController: IDCardViewDelegate {
    func shareOnSlackDidTap() {
        guard let slackUrl = URL(string: EnvironmentConfig.uplusSlackLink) else { return }
        if UIApplication.shared.canOpenURL(slackUrl) {
            UIApplication.shared.open(slackUrl, options: [:], completionHandler: nil)
        }
    }
}

extension ShareMediaOnSlackMissionViewController: SlackShareTextFieldViewDelegate {
    func keyboardShown() {
        self.scrollView.contentOffset.y
    }
}
