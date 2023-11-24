//
//  MissionAndEventCollectionViewHeader.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit

protocol MissionAndEventCollectionViewHeaderDelegate: AnyObject {
    func buttonDidTap(at tag: Int)
}

final class MissionAndEventCollectionViewHeader: UICollectionViewCell {
    weak var delegate: MissionAndEventCollectionViewHeaderDelegate?
       
       private let stack: UIStackView = {
           let stack = UIStackView()
           stack.axis = .horizontal
           stack.distribution = .fillEqually
           stack.translatesAutoresizingMaskIntoConstraints = false
           return stack
       }()
       
       private lazy var missionButton: UIButton = {
           let button = UIButton()
           button.tag = 0
           button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
           button.backgroundColor = .white
           button.setTitleColor(.black, for: .normal)
           button.setTitle("미션", for: .normal)
           return button
       }()
       
       private lazy var eventButton: UIButton = {
           let button = UIButton()
           button.tag = 1
           button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
           button.backgroundColor = .white
           button.setTitleColor(.black, for: .normal)
           button.setTitle("이벤트", for: .normal)
           return button
       }()
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           contentView.addSubview(stack)
           stack.addArrangedSubview(missionButton)
           stack.addArrangedSubview(eventButton)
           
           NSLayoutConstraint.activate([
               stack.topAnchor.constraint(equalTo: self.contentView.topAnchor),
               stack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
               stack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
               stack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
           ])
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
       @objc func buttonDidTap(_ sender: UIButton) {
           delegate?.buttonDidTap(at: sender.tag)
       }
}
