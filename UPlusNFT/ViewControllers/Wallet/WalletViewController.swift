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
    private let numberOfNftsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private let numberOfRaffles: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
    }
    
    // MARK: - Init
    init(vm: WalletViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension WalletViewController {
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            self.vm.$nfts
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.nftsCollectionView.reloadData()
                    
                    self.numberOfNftsLabel.text = "My NFTs " + String(describing: $0.count) + "개"
                }
                .store(in: &bindings)
            
            self.vm.$rewards
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.numberOfRaffles.setTitle("보유 경품 " + String(describing: $0.count) + "개", for: .normal)
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

extension WalletViewController {
    private func setUI() {
        self.view.addSubviews(self.numberOfNftsLabel,
                              self.nftsCollectionView,
                              self.numberOfRaffles)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.numberOfNftsLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.numberOfNftsLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.numberOfNftsLabel.trailingAnchor, multiplier: 2),
            
            self.nftsCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.numberOfNftsLabel.bottomAnchor, multiplier: 1),
            self.nftsCollectionView.leadingAnchor.constraint(equalTo: self.numberOfNftsLabel.leadingAnchor),
            self.nftsCollectionView.trailingAnchor.constraint(equalTo: self.numberOfNftsLabel.trailingAnchor),
            
            self.numberOfRaffles.topAnchor.constraint(equalToSystemSpacingBelow: self.nftsCollectionView.bottomAnchor, multiplier: 1),
            self.numberOfRaffles.leadingAnchor.constraint(equalTo: self.numberOfNftsLabel.leadingAnchor),
            self.numberOfRaffles.trailingAnchor.constraint(equalTo: self.numberOfNftsLabel.trailingAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.numberOfRaffles.bottomAnchor, multiplier: 2)
        ])
        self.numberOfNftsLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
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
        return CGSize(width: self.view.frame.width / 1.5,
                      height: self.nftsCollectionView.frame.height)
    }
}
