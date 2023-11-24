//
//  SafariViewController.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/24.
//

import Foundation
import UIKit
import SafariServices

final class SafariViewController: UIViewController {
    var url: URL? {
        didSet {
            configure()
        }
    }
    private var safariViewController: SFSafariViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        if let safariViewController = safariViewController {
            safariViewController.willMove(toParent: self)
            safariViewController.view.removeFromSuperview()
            safariViewController.removeFromParent()
            self.safariViewController = nil
        }
        guard let url = url else { return }
        
        let newSafariViewController = SFSafariViewController(url: url)
        addChild(newSafariViewController)
        newSafariViewController.view.frame = view.frame
        view.addSubview(newSafariViewController.view)
        newSafariViewController.didMove(toParent: self)
        self.safariViewController = newSafariViewController
        NotificationCenter.default.addObserver(forName: .twitterCallback, object: nil, queue: nil) { notification in
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
}
