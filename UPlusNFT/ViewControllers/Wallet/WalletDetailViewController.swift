//
//  WalletDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import UIKit

final class WalletDetailViewController: UIViewController {
    
    private let vm: WalletViewViewModel
    
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
        collection.register(WalletDetailCollectionViewCell.self,
                            forCellWithReuseIdentifier: WalletDetailCollectionViewCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: - Init
    init(vm: WalletViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
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
        self.configure()
    }

}

extension WalletDetailViewController {
    private func configure() {
        self.numberOfNftsLabel.text = String(format: WalletConstants.totalNfts, self.vm.nfts.count)
    }
}

extension WalletDetailViewController {
    private func setUI() {
        self.view.addSubviews(self.numberOfNftsLabel,
                              self.nftsCollectionView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.numberOfNftsLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.numberOfNftsLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            
            self.nftsCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.numberOfNftsLabel.bottomAnchor, multiplier: 2),
            self.nftsCollectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftsCollectionView.trailingAnchor, multiplier: 2),
            self.nftsCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        self.nftsCollectionView.delegate = self
        self.nftsCollectionView.dataSource = self
    }
}

extension WalletDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.nfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletDetailCollectionViewCell.identifier, for: indexPath) as? WalletDetailCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: vm.nfts[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 2.2, height: self.view.frame.height / 3)
    }
}

extension WalletDetailViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vm = self.vm.nfts[indexPath.item]
        let vc = NFTDetailViewController(vm: vm)
        
        show(vc, sender: self)
    }
}
