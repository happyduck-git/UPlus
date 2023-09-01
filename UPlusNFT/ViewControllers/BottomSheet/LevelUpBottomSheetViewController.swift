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
    
    private let benefitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MyPageConstants.benefit
        label.textColor = UPlusColor.blue03
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let couponStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let couponLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MyPageConstants.coffee
        label.textColor = UPlusColor.mint05
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        return label
    }()
    
    private let couponSubLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MyPageConstants.coffee
        label.textColor = UPlusColor.gray08
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        return label
    }()
    
    private let eventView: UILabel = {
        let label = UILabel()
        label.text = MyPageConstants.eventOpened
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let raffleView: UIImageView = {
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
            self.vm.nft
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let nft = $0
                    else { return }

                    self.levelLabel.text = String(format: MyPageConstants.levelUp, self.vm.level.rawValue)
                    self.couponLabel.text = self.vm.level.coupon
            //        let raffle = self.vm.level.raffle // <- Raffle도 레벨에 따라 구분해야 하는 경우에 사용
                    
                    var imageName: String = "\(self.vm.level.rawValue)"
                    
                    
                     guard let url = URL(string: nft.nftContentImageUrl) else {
                     UPlusLogger.logger.warning("Error converting to url.")
                         return
                     }
                    print("Level up nft image urlString: \(nft.nftContentImageUrl)")
                    print("Level up nft image URL: \(url)")
                    
                     Task {
                         do {
                             self.topImageView.image = try await ImagePipeline.shared.image(for: url)
                         }
                         catch {
                             UPlusLogger.logger.error("Error fetching image -- \(error).")
                         }
                     }     
                    
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

// MARK: - Set UI & Layout
extension LevelUpBottomSheetViewController {
    private func setUI() {
        
        self.middleContainer.addSubviews(self.benefitContainerView)
        
        self.benefitContainerView.addSubviews(self.couponStack,
                                              self.benefitLabel,
                                              self.raffleView,
                                              self.eventView)
        
        self.couponStack.addArrangedSubviews(self.couponLabel,
                                             self.couponSubLabel)
        
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
            self.benefitLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.topAnchor, multiplier: 2),
            self.benefitLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.leadingAnchor, multiplier: 3),
            self.benefitContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.benefitLabel.trailingAnchor, multiplier: 3),

            self.couponStack.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitLabel.bottomAnchor, multiplier: 1),
            self.couponStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.leadingAnchor, multiplier: 2),
            self.benefitContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.couponStack.bottomAnchor, multiplier: 2),
//            self.couponStack.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3.5),
            
            self.eventView.topAnchor.constraint(equalTo: self.couponStack.topAnchor),
            self.eventView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.couponStack.trailingAnchor, multiplier: 1),
            self.eventView.bottomAnchor.constraint(equalTo: self.couponStack.bottomAnchor),

            self.raffleView.topAnchor.constraint(equalTo: self.couponStack.topAnchor),
            self.raffleView.bottomAnchor.constraint(equalTo: self.couponStack.bottomAnchor),
            self.raffleView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.eventView.trailingAnchor, multiplier: 1),
            self.benefitContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.raffleView.trailingAnchor, multiplier: 2)
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
