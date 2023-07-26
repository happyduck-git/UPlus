//
//  LoadingViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import UIKit

final class LoadingViewController: UIViewController {

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.color = .white
        spinner.style = .large
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemGray
        self.view.alpha = 0.2
        
        self.setUI()
        self.setLayout()
        
        self.spinner.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.spinner.stopAnimating()
    }

}

extension LoadingViewController {
    private func setUI() {
        self.view.addSubview(self.spinner)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}
