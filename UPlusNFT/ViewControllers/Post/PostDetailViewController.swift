//
//  PostDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import UIKit
import Combine

final class PostDetailViewController: UIViewController {

    // MARK: - Dependency
    private let vm: PostDetailViewViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let tableHeader: PostDetailTableViewHeader = {
        let header = PostDetailTableViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    
    private let postDetailTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray4
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        table.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        setLayout()
        setDelegate()
        setNavigationBar()
  
        bind()
        
    }
    
    // MARK: - Init
    init(vm: PostDetailViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private func setUI() {
        view.addSubview(postDetailTable)
        postDetailTable.tableHeaderView = tableHeader
        tableHeader.configure(with: vm)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.tableHeader.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.tableHeader.heightAnchor.constraint(equalToConstant: self.view.frame.height / 2),
            
            self.postDetailTable.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.postDetailTable.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.postDetailTable.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.postDetailTable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    private func setDelegate() {
        self.postDetailTable.delegate = self
        self.postDetailTable.dataSource = self
    }
    
    private func setNavigationBar() {
        if vm.isPostOfCurrentUser {
            let menu = UIMenu(children: [
                UIAction(title: "수정하기", handler: { action in
                    print(action.title)
                    //                    self.showEditVC()
                }),
                UIAction(title: "삭제하기", attributes: .destructive, handler: { action in
                    self.showDeleteUIAlert()
                }),
            ])
            
            let btn = UIButton()
            btn.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
            btn.showsMenuAsPrimaryAction = true
            btn.menu = menu
            let barbutton = UIBarButtonItem(customView: btn)
            navigationItem.rightBarButtonItem = barbutton
        }
    }
    
    private func bind() {
        
        func bindViewToViewModel() {
            
        }
        
        func bindViewModelToView() {

            vm.$tableDataSource
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.postDetailTable.reloadData()
                }
                .store(in: &bindings)
            
            vm.$recomments
                .receive(on: DispatchQueue.main)
                .sink { [weak self] recomment in
                    print("Recomment -- \(recomment)")
                    self?.postDetailTable.reloadData()
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    private func showDeleteUIAlert() {
        let alert = UIAlertController(title: "게시글 삭제", message: "삭제하시겠습니까?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "삭제", style: .default) { _ in
            
            // TODO: Add Delete Post logic (also delete images inside Storage)
            
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(confirm)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
}

extension PostDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = vm.numberOfSections()
        return count == 0 ? 1 : count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "댓글"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
            // TODO: Recomment count에 따라 변동.
            guard let cellVM = vm.viewModelForRow(at: section)
            else { return 1 }
            
            if cellVM.isOpened {
                print("Number of rows in section #\(section) --- \((self.vm.recomments[section]?.count ?? 0) + 1)")
                return (self.vm.recomments[section]?.count ?? 0) + 1
            }
            else {
                return 1
            }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
                return UITableViewCell()
            }
            cell.resetCell()
            
            if indexPath.row == 0 {
                guard let cellVM = vm.viewModelForRow(at: indexPath.section)
                else {
//                    let defaultCell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
//                    var config = defaultCell.defaultContentConfiguration()
//                    config.text = "아직 댓글이 없습니다!"
//                    defaultCell.contentConfiguration = config
//                    return defaultCell
                    return UITableViewCell()
                }
                
                cell.configure(with: cellVM)
                
                return cell
            }
            else {
                guard let recomments = self.vm.recomments[indexPath.section],
                      !recomments.isEmpty
                else {
                    let defaultCell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
                    // recomment == nil || recomment is empty
                    var config = defaultCell.defaultContentConfiguration()
                    config.text = "아직 대댓글이 없습니다!"
                    defaultCell.contentConfiguration = config
                    defaultCell.backgroundColor = .systemGray4
                    return defaultCell
                }
                // recomment != nil nor empty
                let recomment = recomments[indexPath.row - 1]
                let cellVM = CommentTableViewCellModel(
                    type: .normal,
                    id: recomment.recommentId,
                    userId: recomment.recommentAuthorUid,
                    comment: recomment.recommentContentText,
                    imagePath: nil,
                    likeUserCount: nil,
                    recomments: nil,
                    createdAt: recomment.recommentCreatedTime
                )
                cell.backgroundColor = .systemGray4
                cell.configure(with: cellVM)
                return cell
            }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Section tapped \(indexPath.section)")
        if indexPath.row == 0 {
            guard let cellVM = vm.viewModelForRow(at: indexPath.section) else { return }
            cellVM.isOpened = !cellVM.isOpened
            
            self.vm.fetchRecomment(at: indexPath.section, of: cellVM.id)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return view.frame.height / 6
        
    }
    
}

