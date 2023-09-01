//
//  TemplateListView.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/07.
//

import UIKit

final class TemplateListView: UIView {
    
    private lazy var toggleButton = UIButton().then {
        addSubview($0)
    }
    
    private lazy var collectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        let width = (UIScreen.main.bounds.width - 71 * scale) / 4
        $0.itemSize = .init(width: width, height: width)
        $0.minimumLineSpacing = 10 * scale
        $0.minimumInteritemSpacing = 0
        $0.sectionInset = .init(top: 16 * scale, left: 16 * scale, bottom: 16 * scale, right: 16 * scale)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
        $0.register(TemplateCell.self, forCellWithReuseIdentifier: TemplateCell.identifier)
        addSubview($0)
    }
}
