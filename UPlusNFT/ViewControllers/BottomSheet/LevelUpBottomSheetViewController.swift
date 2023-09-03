//
//  LevelUpBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit
import Combine
import Nuke

protocol NftBottomSheetDelegate: AnyObject {
    func redeemButtonDidTap()
}

final class LevelUpBottomSheetViewController: HumpyBottomSheetViewController {
    
    private let vm: LevelUpBottomSheetViewViewModel
    
    //MARK: - Delegate
    weak var delegate: NftBottomSheetDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private let benefitContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10.0
        view.backgroundColor = UPlusColor.gray01
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let benefitTitleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "special-bonus")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let benefitStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10.0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let couponImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "starbucks-americano")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let eventImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "event-open")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let raffleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAssets.raffle)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Init
    init(vm: LevelUpBottomSheetViewViewModel) {
        self.vm = vm
        super.init(defaultHeight: 450)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        
        self.configure()
        self.bind()
    }
    
}

extension LevelUpBottomSheetViewController {
    private func configure() {
        UPlusLogger.logger.debug("LEVEL INFO TO BE SHOWING: \(String(describing: self.vm.level))")
        
        self.topImageView.image = UIImage(named: self.vm.level.avatarImage)
        self.levelLabel.text = String(format: MyPageConstants.levelUp, self.vm.level.rawValue)
        self.couponImage.image = UIImage(named: self.vm.level.couponImage)
        self.raffleImage.image = UIImage(named: self.vm.level.raffleImage)
    }
    
    private func bind() {
        func bindViewToViewModel() {
            self.confirmButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.dismissView {
                        self.delegate?.redeemButtonDidTap()
                    }
                    
                }
                .store(in: &bindings)
        }
        func bindViewModelToView() {
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

// MARK: - Set UI & Layout
extension LevelUpBottomSheetViewController {
    private func setUI() {
        
        self.middleContainer.addSubviews(self.benefitContainerView)
        
        self.benefitContainerView.addSubviews(self.benefitTitleImage,
                                              self.benefitStack)
        
        self.benefitStack.addArrangedSubviews(self.couponImage,
                                              self.raffleImage,
                                              self.eventImage)
        
        self.confirmButton.setTitle(MyPageConstants.redeemLevelUpBenefits, for: .normal)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.benefitContainerView.topAnchor.constraint(equalTo: self.middleContainer.topAnchor),
            self.benefitContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.middleContainer.leadingAnchor, multiplier: 2),
            self.middleContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.trailingAnchor, multiplier: 2),

            self.middleContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.bottomAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            self.benefitTitleImage.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.topAnchor, multiplier: 3),
            self.benefitTitleImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.leadingAnchor, multiplier: 5),
            self.benefitTitleImage.heightAnchor.constraint(equalToConstant: 30),
            self.benefitContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.benefitTitleImage.trailingAnchor, multiplier: 5),

            self.benefitStack.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitTitleImage.bottomAnchor, multiplier: 7),
            self.benefitStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.leadingAnchor, multiplier: 2),
            self.benefitContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.benefitStack.bottomAnchor, multiplier: 2),
            self.benefitContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.benefitStack.trailingAnchor, multiplier: 3)
        ])
        
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct LevelUpBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        let vm = LevelUpBottomSheetViewViewModel(newLevel: 1, tokenId: "10070")
        LevelUpBottomSheetViewController(vm: vm).toPreview()
    }
}
#endif
