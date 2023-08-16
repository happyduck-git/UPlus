//
//  CommentCountMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import Combine

final class CommentCountMissionViewController: BaseMissionViewController {

    //MARK: - Dependency
    private let vm: CommentCountMissionViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    
    private let textField: UITextField = {
        let txtField = UITextField()
        txtField.placeholder = MissionConstants.inputAnswer
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    //MARK: - Init
    init(vm: CommentCountMissionViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        self.hideKeyboardWhenTappedAround()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.bind()
    }

}

extension CommentCountMissionViewController {
    
    private func bind() {
        do {
            let user = try UPlusUser.getCurrentUser()
            
            self.vm.$participated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    if $0 {
                        self.checkAnswerButton.isEnabled = false
                        self.checkAnswerButton.backgroundColor = .systemGray
                        self.checkAnswerButton.setTitle("이미 참여하였습니다.", for: .normal)
                    }
                    
                }
                .store(in: &bindings)
            
            self.vm.$combinations
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let imageCount = $0["ImageUrls"] as? [URL]
                    
                    /*
                    self.label.text = "ImageUrls: \(imageCount?.count ?? 0)개\n\n"
                    + "Comments: \($0["comments"])\n\n"
                    + "commentCountMap: \($0["commentCountMap"])"
                     */
                }
                .store(in: &bindings)

            self.checkAnswerButton
                .tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let text = textField.text
                    else { return }
                    
                    self.vm.comment = text
                    self.vm.comments.append(contentsOf: [user.userNickname, text])
                    let val = self.vm.commentCountMap[text] ?? 0
                    self.vm.commentCountMap[text] = val + 1
                    
                    self.vm.saveComment()
                    self.checkAnswerButton.isEnabled = false
                    self.checkAnswerButton.backgroundColor = .systemGray
                }
                .store(in: &bindings)
        }
        catch {
         print("Error getting user info from UserDefaults -- \(error)")
        }
  
    }
    
}

//MARK: - Set UI & Layout
extension CommentCountMissionViewController {
    private func setUI() {
        self.view.addSubviews(
            self.textField
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.textField.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 2),
            self.textField.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.textField.trailingAnchor, multiplier: 2),
            self.textField.heightAnchor.constraint(equalToConstant: 80)
        ])
        
    }
}
