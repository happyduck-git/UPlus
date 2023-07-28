//
//  DailyRoutineMissionDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/27.
//

import UIKit

final class DailyRoutineMissionDetailViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: DailyRoutineMissionDetailViewViewModel
    
    // MARK: - UI Elements
    private let quizDescription: UILabel = {
        let label = UILabel()
        label.text = "갓생미션 인증서와 300만원 경품권을 받으세요!"
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quizTitle: UILabel = {
        let label = UILabel()
        label.text = "매일 6000보 걷기"
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.main, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let eventContentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let eventLabel: UILabel = {
        let label = UILabel()
        label.text = "이벤트 기간 D-23"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stampCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collection.register(DailyRoutineMissionStampCollectionViewCell.self, forCellWithReuseIdentifier: DailyRoutineMissionStampCollectionViewCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let uploadImageButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: ImageAsset.share), for: .normal)
        button.titleLabel?.text = "날짜, 시간, 걸음수가 포함된 사진"
        button.alignVerticalCenter()
        return button
    }()
    
    // MARK: - Init
    init(vm: DailyRoutineMissionDetailViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemGray4
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.vm.getAtheleteMissions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.eventContentView.layer.cornerRadius = self.eventContentView.frame.height / 3
    }
}

extension DailyRoutineMissionDetailViewController {
    
    private func setDelegate() {
        self.stampCollectionView.delegate = self
        self.stampCollectionView.dataSource = self
    }
    
    private func setUI() {
        self.view.addSubviews(self.quizDescription,
                              self.quizTitle,
                              self.eventContentView,
                              self.stampCollectionView,
                              self.uploadImageButton)
        
        self.eventContentView.addSubview(self.eventLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.quizDescription.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.quizDescription.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizDescription.trailingAnchor, multiplier: 2),
            
            self.quizTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.quizDescription.bottomAnchor, multiplier: 1),
            self.quizTitle.leadingAnchor.constraint(equalTo: self.quizDescription.leadingAnchor),
            self.quizTitle.trailingAnchor.constraint(equalTo: self.quizDescription.trailingAnchor),
            
            self.eventContentView.topAnchor.constraint(equalToSystemSpacingBelow: self.quizTitle.bottomAnchor, multiplier: 2),
            self.eventContentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.eventContentView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizTitle.leadingAnchor, multiplier: 10),
            self.quizTitle.trailingAnchor.constraint(equalToSystemSpacingAfter: self.eventContentView.trailingAnchor, multiplier: 10),
            self.eventContentView.heightAnchor.constraint(equalToConstant: 40),
            
            self.stampCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.eventContentView.bottomAnchor, multiplier: 2),
            self.stampCollectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.stampCollectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.stampCollectionView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        NSLayoutConstraint.activate([
            self.eventLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.eventContentView.topAnchor, multiplier: 1),
            self.eventLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.eventContentView.leadingAnchor, multiplier: 1),
            self.eventContentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.eventLabel.trailingAnchor, multiplier: 1),
            self.eventContentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.eventLabel.bottomAnchor, multiplier: 1)
        ])
        
    }
    
}

extension DailyRoutineMissionDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyRoutineMissionStampCollectionViewCell.identifier, for: indexPath) as? DailyRoutineMissionStampCollectionViewCell else {
            fatalError()
        }
        
        cell.bind(with: self.vm)
        cell.contentView.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 20, height: self.stampCollectionView.frame.height)
    }
}

/*
 
 Task {
 do {
 
 // 1. Check missions
 let missions = try await FirestoreManager.shared.getDailyAthleteMission()
 // 2. Check participation status (in user_state_map)
 let statusMap = missions.compactMap {
 ($0.missionId, $0.missionUserStateMap)
 }
 
 // 3. if status is succeeded get point / if pending or failed show the status
 
 print("Current User: \(statusMap)")
 }
 catch {
 print("Error fetching athlete missions: \(error)")
 }
 }
 
 */
