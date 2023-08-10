//
//  WeeklyAnswerQuizMissionDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit
import Combine

final class WeeklyAnswerQuizMissionDetailViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: ChoiceQuizzesViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Init
    init(vm: ChoiceQuizzesViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .systemGray6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private let quizTitle: UILabel = {
        let label = UILabel()
        label.text = "초성 미션"
        label.textColor = .systemGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.head4, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quizQuestion: UILabel = {
        let label = UILabel()
        label.text = "초성에 맞춰 단어를 입력해주세요"
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.head4, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let anwerInputTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let quizCaptionCollections: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(WeeklyAnswerQuizMissionCollectionViewCell.self, forCellWithReuseIdentifier: WeeklyAnswerQuizMissionCollectionViewCell.identifier)
        collection.backgroundColor = .systemGray6
        collection.alwaysBounceVertical = true
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("정답 확인하기!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.bind()
    }
    
}

extension WeeklyAnswerQuizMissionDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataSource = self.vm.mission as! ShortAnswerQuizMission
        return dataSource.missionAnswerQuizzes.count
         
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataSource = self.vm.mission as! ShortAnswerQuizMission
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyAnswerQuizMissionCollectionViewCell.identifier, for: indexPath) as? WeeklyAnswerQuizMissionCollectionViewCell
        else {
            fatalError()
        }

        let quizCaption = dataSource.missionAnswerQuizzes
        
        let index = quizCaption.index(quizCaption.startIndex, offsetBy: indexPath.item)
        let char = quizCaption[index]
        
//        cell.configure(with: char)
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let dataSource = self.vm.dataSource as! ShortAnswerQuizMission
//        
//        let numberOfCells = dataSource
//        return CGSize(width: self.quizCaptionCollections.frame.width / CGFloat(numberOfCells) - CGFloat(2*numberOfCells), height: self.quizCaptionCollections.frame.height / 3.0)
//    }
}

extension WeeklyAnswerQuizMissionDetailViewController {
    
    private func setUI() {
        self.view.addSubviews(quizTitle,
                              quizQuestion,
                              anwerInputTextField,
                              quizCaptionCollections,
                              submitButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.quizTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            self.quizTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.quizQuestion.topAnchor.constraint(equalToSystemSpacingBelow: self.quizTitle.bottomAnchor, multiplier: 2),
            self.quizQuestion.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizQuestion.trailingAnchor, multiplier: 2),
            
            self.anwerInputTextField.topAnchor.constraint(equalToSystemSpacingBelow: self.quizQuestion.bottomAnchor, multiplier: 1),
            self.anwerInputTextField.heightAnchor.constraint(equalToConstant: self.view.frame.height / 12),
            self.anwerInputTextField.leadingAnchor.constraint(equalTo: self.quizQuestion.leadingAnchor),
            self.anwerInputTextField.trailingAnchor.constraint(equalTo: self.quizQuestion.trailingAnchor),
            
            self.quizCaptionCollections.topAnchor.constraint(equalToSystemSpacingBelow: self.anwerInputTextField.bottomAnchor, multiplier: 2),
            self.quizCaptionCollections.leadingAnchor.constraint(equalTo: self.quizQuestion.leadingAnchor),
            self.quizCaptionCollections.trailingAnchor.constraint(equalTo: self.quizQuestion.trailingAnchor),
            self.quizCaptionCollections.heightAnchor.constraint(equalToConstant: self.view.frame.height / 5),
            
            self.submitButton.topAnchor.constraint(equalToSystemSpacingBelow: self.quizCaptionCollections.bottomAnchor, multiplier: 1),
            self.submitButton.leadingAnchor.constraint(equalTo: self.quizQuestion.leadingAnchor),
            self.submitButton.trailingAnchor.constraint(equalTo: self.quizQuestion.trailingAnchor)
        ])
    }
    
    private func setDelegate() {
        self.quizCaptionCollections.delegate = self
        self.quizCaptionCollections.dataSource = self
    }
    
}

// MARK: - Bind
extension WeeklyAnswerQuizMissionDetailViewController {
    
    private func bind() {
        func bindViewToViewModel() {
            self.anwerInputTextField.textPublisher
                .removeDuplicates()
                .map({
                    return !$0.isEmpty
                })
                .assign(to: \.textExists, on: self.vm)
                .store(in: &bindings)
            
            self.submitButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let dataSource = self.vm.mission as! ShortAnswerQuizMission
                    
                    let answer = dataSource.missionAnswerQuizzes
                    if answer[1] == self.anwerInputTextField.text {
                        // TODO: Show 정답 View Controller
                        print("정답입니다.")
                    } else {
                        // TODO: Show 오답
                        print("오답입니다.")
                    }
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            self.vm.$textExists
                .receive(on: DispatchQueue.main)
                .sink {
                    let color: UIColor = $0 ? .black : .systemGray3
                    let isEnabled: Bool = $0 ? true : false
                    
                    self.submitButton.backgroundColor = color
                    self.submitButton.isEnabled = isEnabled
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}
