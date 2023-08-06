//
//  WalletViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/04.
//

import UIKit

final class WalletViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: WalletViewViewModel
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemYellow
    }
    
    // MARK: - Init
    init(vm: WalletViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension WalletViewController {
    
}
