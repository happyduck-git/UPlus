//
//  InsetLabelView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import UIKit

final class InsetLabelView: UIView {

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.gray06
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure
extension InsetLabelView {
    private func configure() {
        self.backgroundColor = UPlusColor.gray02
    }
}

// MARK: - Set UI & Layout
extension InsetLabelView {
    
    private func setUI() {
        self.addSubview(self.nameLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.nameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nameLabel.trailingAnchor, multiplier: 1),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.nameLabel.bottomAnchor, multiplier: 1)
        ])
    }
}

extension InsetLabelView {
    
    func setNameTitle(text: String) {
        self.nameLabel.text = text
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct InsetLabelViewPreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = InsetLabelView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
