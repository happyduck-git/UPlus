//
//  VipHolderBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/19.
//

import UIKit
import Combine

protocol VipHolderBottomSheetViewControllerDelegate: AnyObject {
    func userVipPointSaveStatus(status: Bool)
}

final class VipHolderBottomSheetViewController: BottomSheetViewController {
    
    //MARK: - Dependency
    private let vm: VipHolderBottomSheetViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Delegate
    weak var delegate: VipHolderBottomSheetViewControllerDelegate?
    
    //MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.text = MyPageConstants.vipBenefitTitle
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UPlusColor.grayBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let benefitContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UPlusColor.blue03
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let benefitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = MyPageConstants.vipPoints
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let greetingsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.text = " "
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .heavy)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var receiveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 10.0
        button.setTitleColor(.white, for: .normal)
        button.setTitle(MissionConstants.retrieve, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    init(vm: VipHolderBottomSheetViewViewModel) {
        self.vm = vm
        super.init(defaultHeight: 480)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        
        self.configure()
        self.bind()
    }
    
}

// MARK: - Configure
extension VipHolderBottomSheetViewController {
    
    private func configure() {
        self.greetingsLabel.text = String(format: MyPageConstants.vipHolderGreeting, self.vm.user.userNickname)
    }
    
}

// MARK: - Bind
extension VipHolderBottomSheetViewController {
    
    private func bind() {
        
        func bindViewToViewModel() {
         
            self.receiveButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.levelUpDidTap()
                }
                .store(in: &bindings)
            
        }
        
        func bindViewModelToView() {
            
            self.vm.saveStatus
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.delegate?.userVipPointSaveStatus(status: $0)
                }
                .store(in: &bindings)
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }

}

extension VipHolderBottomSheetViewController {
    
    private func setUI() {
        self.containerView.addSubviews(self.titleLabel,
                                       self.nftImageView,
                                       self.benefitContainerView,
                                       self.greetingsLabel,
                                       self.receiveButton)
        
        self.benefitContainerView.addSubviews(self.benefitLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 3),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),
            
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 4),
            self.nftImageView.widthAnchor.constraint(equalToConstant: 150),
            self.nftImageView.heightAnchor.constraint(equalToConstant: 150),
            self.nftImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            
            self.benefitContainerView.centerYAnchor.constraint(equalTo: self.nftImageView.bottomAnchor),
            self.benefitContainerView.centerXAnchor.constraint(equalTo: self.nftImageView.centerXAnchor),
            
            self.greetingsLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.bottomAnchor, multiplier: 4),
            self.greetingsLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 1),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.greetingsLabel.trailingAnchor, multiplier: 1),
            
            self.receiveButton.topAnchor.constraint(equalToSystemSpacingBelow: self.greetingsLabel.bottomAnchor, multiplier: 3),
            self.receiveButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.receiveButton.trailingAnchor, multiplier: 2),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.receiveButton.bottomAnchor, multiplier: 3)
        ])
        
        NSLayoutConstraint.activate([
            self.benefitLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.topAnchor, multiplier: 1),
            self.benefitLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.leadingAnchor, multiplier: 1),
            self.benefitContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.benefitLabel.trailingAnchor, multiplier: 1),
            self.benefitContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.benefitLabel.bottomAnchor, multiplier: 1)
        ])
        
        self.nftImageView.layer.cornerRadius = 150 / 2
        
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.greetingsLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.receiveButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.benefitContainerView.layer.cornerRadius = self.benefitContainerView.frame.height / 2
    }
}

extension VipHolderBottomSheetViewController {
    
    private func levelUpDidTap() {
        Task {
            async let _ = self.vm.requestVipNft()
            async let _ = self.vm.saveVipInitialPoint()
        }
        
        self.dismissView {
            print("Vip holder bottom sheet dismissed.")
        }
    }
    
}

 
#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct VipHolderBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        let user = UPlusUser(userIndex: 9, userUid: nil, userEmail: "adf@gmail.com", userNickname: "adf", userWalletAddress: nil, userAccountCreationTime: nil, userHasVipNft: true, userTypeMissionArrayMap: nil, userIsAdmin: false)
        let vm = VipHolderBottomSheetViewViewModel(user: user)
        VipHolderBottomSheetViewController(vm: vm).toPreview()
    }
}
#endif
