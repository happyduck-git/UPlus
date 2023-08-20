//
//  WalletViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/04.
//

import UIKit
import Combine

final class WalletViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: WalletViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let myNftsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = WalletConstants.myNfts
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let numberOfNftsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.h2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let showAllButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(UPlusColor.mint04, for: .normal)
        button.setTitle(WalletConstants.showAll, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nftsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(WalletCollectionViewCell.self,
                            forCellWithReuseIdentifier: WalletCollectionViewCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let walletAdButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UPlusColor.gray02
        button.setImage(UIImage(named: ImageAsset.walletGray), for: .normal)
        button.setTitle(WalletConstants.walletAddress, for: .normal)
        button.setTitleColor(UPlusColor.gray06, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let numberOfRaffles: RightArrowButton = {
        let button = RightArrowButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: WalletViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.walletAdButton.layer.cornerRadius = self.walletAdButton.frame.height / 2
    }
    
}

extension WalletViewController {
    private func bind() {
        func bindViewToViewModel() {
            self.showAllButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.showAllButtonDidTap()
                }
                .store(in: &bindings)
            
            self.walletAdButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let vc = WalletAddressBottomSheetViewController()
                    vc.modalPresentationStyle = .overCurrentContext

                    self.present(vc, animated: false)
                }
                .store(in: &bindings)
            
            self.numberOfRaffles.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let vm = RewardsViewViewModel(rewards: self.vm.rewards)
                    let vc = RewardsViewController(vm: vm)
                    
                    self.show(vc, sender: self)
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            self.vm.$nfts
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.nftsCollectionView.reloadData()
                    
                    self.numberOfNftsLabel.text = String(format: WalletConstants.rewardsUnit, String(describing: $0.count))
                }
                .store(in: &bindings)
            
            self.vm.$rewards
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.numberOfRaffles.setSubTitle(String(describing: $0.count))
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

extension WalletViewController {
    private func showAllButtonDidTap () {
        let vc = WalletDetailViewController(vm: self.vm)
        self.show(vc, sender: self)
    }
}

extension WalletViewController {
    private func setUI() {
        self.view.addSubviews(self.myNftsLabel,
                              self.numberOfNftsLabel,
                              self.showAllButton,
                              self.nftsCollectionView,
                              self.walletAdButton,
                              self.numberOfRaffles)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.myNftsLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 5),
            self.myNftsLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            
            self.numberOfNftsLabel.bottomAnchor.constraint(equalTo: self.myNftsLabel.bottomAnchor),
            self.numberOfNftsLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.myNftsLabel.trailingAnchor, multiplier: 2),
            
            self.showAllButton.centerYAnchor.constraint(equalTo: self.myNftsLabel.centerYAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.showAllButton.trailingAnchor, multiplier: 2),
            
            self.nftsCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.numberOfNftsLabel.bottomAnchor, multiplier: 3),
            self.nftsCollectionView.leadingAnchor.constraint(equalTo: self.myNftsLabel.leadingAnchor),
            self.nftsCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            self.walletAdButton.topAnchor.constraint(equalToSystemSpacingBelow: self.nftsCollectionView.bottomAnchor, multiplier: 4),
            self.walletAdButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.walletAdButton.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3),
            self.walletAdButton.heightAnchor.constraint(equalToConstant: 32),
            
            self.numberOfRaffles.topAnchor.constraint(equalToSystemSpacingBelow: self.walletAdButton.bottomAnchor, multiplier: 4),
            self.numberOfRaffles.leadingAnchor.constraint(equalTo: self.myNftsLabel.leadingAnchor),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.numberOfRaffles.trailingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.numberOfRaffles.bottomAnchor, multiplier: 3)
        ])
        
        self.walletAdButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.numberOfRaffles.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setDelegate() {
        self.nftsCollectionView.delegate = self
        self.nftsCollectionView.dataSource = self
    }
}

extension WalletViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.vm.nfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletCollectionViewCell.identifier, for: indexPath) as? WalletCollectionViewCell else {
            fatalError()
            
        }
        
        cell.configure(with: self.vm.nfts[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 1.3,
                      height: self.nftsCollectionView.frame.height)
    }

}
