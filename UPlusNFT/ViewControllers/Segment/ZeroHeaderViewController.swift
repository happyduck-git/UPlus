//
//  ZeroHeaderViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/31.
//

import UIKit

class ZeroHeaderViewController: UIViewController {

    private let image: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: ImageAssets.company)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
        self.view.addSubview(image)
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            image.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.view.bottomAnchor.constraint(equalToSystemSpacingBelow: self.image.bottomAnchor, multiplier: 3)
        ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
