//
//  GiftViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import UIKit
import Combine
import Nuke

final class GiftViewController: UIViewController {

    // MARK: - Dependency
    private let vm: GiftViewControllerViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let giftDetailView: GiftDetailView = {
       let view = GiftDetailView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let receiverInputView: GiftSendView = {
       let view = GiftSendView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let infoTitle: UILabel = {
       let label = UILabel()
        label.text = GiftConstants.info
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let infoDetailTitle: UILabel = {
       let label = UILabel()
        label.text = GiftConstants.infoDetail
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sendGiftButton: UIButton = {
        let button = UIButton()
        button.setTitle(GiftConstants.sendGift, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UPlusColor.gray03
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: GiftViewControllerViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        self.receiverInputView.bind(vm: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = .systemGray6
        
        self.setUI()
        self.setLayout()
        self.bind()
        self.configure()
    }
  

}

// MARK: - Configure
extension GiftViewController {
    private func configure() {
        self.giftDetailView.configure(imageUrl: self.vm.nft.nftContentImageUrl,
                                      nftName: String(describing: self.vm.nft.nftType) + String(describing: self.vm.nft.nftTokenId))
    }
}

// MARK: - Bind with View Model
extension GiftViewController {
    private func bind() {
        func bindViewToViewModel() {
            self.sendGiftButton.tapPublisher
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
        
                    Task {
                        
                        let isAvailable = await self.vm.checkIsValidEmail(username: self.vm.username)
                        if isAvailable {
                            self.receiverInputView.hideInfoLabel()
                            
                            let result = await self.vm.sendNft()
                            if result {
                                // TODO: 성공완료 시 Show Bottom Sheet
                                UPlusLogger.logger.info("선물 보내기 완료")
                                
                                let vc = GiftSentBottomSheetViewController()
                                vc.delegate = self
                                vc.modalPresentationStyle = .overCurrentContext

                                self.present(vc, animated: false)
                                
                            } else {
                                // TODO: 실패 alert
                                UPlusLogger.logger.error("선물 보내기 실패")
                                self.showAlert()
                            }
                            
                        } else {
                            // TODO: show warning label
                            self.receiverInputView.setInfoLabelText()
                        }
                    }

                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            self.vm.$username
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let bgColor: UIColor = $0.isEmpty ? UPlusColor.buttonDeactivated : UPlusColor.buttonActivated
                    let txtColor: UIColor = $0.isEmpty ? .white : UPlusColor.gray08
                    let isActivated: Bool = $0.isEmpty ? false : true
                    
                    self.sendGiftButton.backgroundColor = bgColor
                    self.sendGiftButton.setTitleColor(txtColor, for: .normal)
                    self.sendGiftButton.isUserInteractionEnabled = isActivated
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

extension GiftViewController {
    private func showAlert() {
        let action = UIAlertAction(title: "확인", style: .cancel)
        let alert = UIAlertController(title: "선물 전송에 실패하였습니다.", message: "선물 전송에 실패하였습니다. 다시 시도해 주세요.", preferredStyle: .alert)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

// MARK: - Set UI & Layout
extension GiftViewController {
    
    private func setUI() {
        self.view.addSubviews(self.giftDetailView,
                              self.receiverInputView,
                              self.infoTitle,
                              self.infoDetailTitle,
                              self.sendGiftButton)
    }
    
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.giftDetailView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.giftDetailView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.giftDetailView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.giftDetailView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 4),
            
            self.receiverInputView.topAnchor.constraint(equalToSystemSpacingBelow: self.giftDetailView.bottomAnchor, multiplier: 2),
            self.receiverInputView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.receiverInputView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.receiverInputView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 5),
            
            self.infoTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.receiverInputView.bottomAnchor, multiplier: 3),
            self.infoTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.infoDetailTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.infoTitle.bottomAnchor, multiplier: 1),
            self.infoDetailTitle.leadingAnchor.constraint(equalTo: self.infoTitle.leadingAnchor),
            self.infoDetailTitle.trailingAnchor.constraint(equalTo: self.infoTitle.trailingAnchor),
            
            self.sendGiftButton.topAnchor.constraint(equalToSystemSpacingBelow: self.infoDetailTitle.bottomAnchor, multiplier: 4),
            self.sendGiftButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.sendGiftButton.trailingAnchor, multiplier: 2),
            self.sendGiftButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 16)
            ])
        
        self.giftDetailView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.receiverInputView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.infoTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.sendGiftButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

extension GiftViewController: GiftSentBottomSheetViewControllerDelegate {
    func completeButtonDidTap() {
        guard let vcs = self.navigationController?.viewControllers else { return }
        for vc in vcs {
            if vc is WalletViewController {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
}

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//struct ViewController_Preview: PreviewProvider {
//    static var previews: some View {
//        GiftViewController().toPreview()
//    }
//}
//#endif
