//
//  HomeViewController.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/01/27.
//

import UIKit
import Social

import ReactorKit
import Then
import SnapKit
import RxDataSources

final class HomeViewController2: UIViewController, View {
    
    // MARK: - UI Component
    private lazy var backgroundView = UIImageView().then {
        $0.image = .init(named: "background")
        $0.contentMode = .scaleAspectFill
        view.addSubview($0)
    }
        
    private lazy var emptyView = UIView().then {
        $0.isHidden = true
        view.addSubview($0)
    }
    private lazy var emptyImageView = UIImageView().then {
        $0.image = .init(named: "empty")
        $0.contentMode = .scaleAspectFit
        emptyView.addSubview($0)
    }
    
    private lazy var emptyTitleLabel = UILabel().then {
        $0.text = "No NFTs to display!\nPlease check your nft"
        $0.textColor = .white01
        $0.font = .subtitle02
        $0.textAlignment = .center
        $0.numberOfLines = 0
        emptyView.addSubview($0)
    }

    private lazy var allDataSource = RxCollectionViewSectionedReloadDataSource<NFTSection>(configureCell: { _, collectionView, indexPath, reactor in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NFTCell.identifier, for: indexPath) as! NFTCell
        cell.reactor = reactor
        return cell
    })
    
    private lazy var allCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        let width = (UIScreen.main.bounds.width - (55 * scale)) / 2
        $0.itemSize = .init(width: width, height: (width + 60) * scale)
        $0.minimumLineSpacing = 15 * scale
        $0.minimumInteritemSpacing = 15 * scale
        $0.sectionInset = .init(top: 0, left: 20 * scale, bottom: 20 * scale, right: 20 * scale)
    }
    
    private lazy var allCollectionView = UICollectionView(frame: .zero, collectionViewLayout: allCollectionViewLayout).then {
        $0.backgroundColor = .clear
        $0.register(NFTCell.self, forCellWithReuseIdentifier: NFTCell.identifier)
        view.addSubview($0)
    }
    
    private lazy var backButton = UIButton(type: .system).then {
        $0.setTitle("Back", for: .normal)
        $0.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        view.addSubview($0)
    }
    
    // MARK: - Property
    let twitterService = TwitterService.shared
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Init
    init(reactor: HomeViewReactor2) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    func bind(reactor: HomeViewReactor2) {
        setUI()
        bindState(reactor)
        bindAction(reactor)
    }
    
    // MARK: - Private Method
    private func setUI() {
        view.backgroundColor = .bg
        
        backgroundView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
                
        emptyView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints {
            $0.width.height.equalTo(180 * scale)
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        emptyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(20 * scale)
            $0.centerX.equalToSuperview()
        }
        
        allCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        backButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func bindState(_ reactor: HomeViewReactor2) {
        reactor.state.map { $0.nftAllSections }
            .bind(to: allCollectionView.rx.items(dataSource: allDataSource))
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.openNFTView }
            .bind { [weak self] nft in
                self?.presentTemplateCreateView(nft: nft)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isEmpty }
            .bind(to: allCollectionView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { !$0.isEmpty }
            .bind(to: emptyView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func bindAction(_ reactor: HomeViewReactor2) {
        allCollectionView.rx.itemSelected
            .map(Reactor.Action.allSelecte(indexPath:))
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.just(Reactor.Action.reload)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func presentTemplateCreateView(nft: NFTProtocol) {
        guard let reactor = reactor else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            let vc = TemplateCreateViewController2(reactor: reactor.dependency.templateCreateViewReactorFactory.create(payload: .init(nft: nft, format: .video)))
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        print("HomeViewController2.presentTemplateCreateView(nft:) : nft: \(nft).")
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}
