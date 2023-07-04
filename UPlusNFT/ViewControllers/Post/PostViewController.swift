//
//  PostViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/22.
//

import UIKit
import FirebaseAuth
import Combine

final class PostViewController: UIViewController {
    
    private let vm: PostViewViewModel
    private var bindings = Set<AnyCancellable>()
    
    private let postsTableView: UITableView = {
        let table = UITableView()
        table.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        let writePostBarButtomItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(showWritePostVC))
        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logOutDidTap))
        navigationItem.rightBarButtonItems = [writePostBarButtomItem, logoutBarButtonItem]

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "메인화면"
        view.backgroundColor = .tertiarySystemBackground
        vm.fetchAllInitialPosts()
        
        setUI()
        setLayout()
        setDelegate()
        bind()
 
    }
    
    // MARK: - Init
    init(vm: PostViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private func setUI() {
        view.addSubviews(postsTableView)
        
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.postsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.postsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.postsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            self.postsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        postsTableView.delegate = self
        postsTableView.dataSource = self
    }
    
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            
            vm.$tableDataSource
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.postsTableView.reloadData()
            }
            .store(in: &bindings)
            
            vm.$didLoadAdditionalPosts
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.postsTableView.reloadData()
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    @objc
    private func showWritePostVC() {
        let vm = WritePostViewViewModel()
        let vc = WritePostViewController(type: .newPost, vm: vm)
        
        navigationController?.modalPresentationStyle = .fullScreen
        self.show(vc, sender: self)
    }
    
    @objc
    private func logOutDidTap() {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        }
        catch {
            print("Error logout user \(error.localizedDescription)")
        }
    }
    
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        let vm = vm.cellForRow(at: indexPath.row)
        cell.configure(with: vm)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.modalPresentationStyle = .fullScreen
        
        let vm = vm.postDetailViewModel(at: indexPath.row)
        
        switch vm.postType {
        case .article:
            let vc = PostDetailViewController(vm: vm)
            self.show(vc, sender: self)
        case .multipleChoice:
            let vm = self.vm.multipleChoiceViewModel(postId: vm.postId)
            let vc = CampaignPostViewController(postType: .multipleChoice,
                                                vm: vm)
            self.show(vc, sender: self)
        case .shortForm:
            let vm = self.vm.multipleChoiceViewModel(postId: vm.postId)
            let vc = CampaignPostViewController(postType: .shortForm,
                                                vm: vm)
            self.show(vc, sender: self)
        case .bestComment:
            let vm = self.vm.multipleChoiceViewModel(postId: vm.postId)
            let vc = CampaignPostViewController(postType: .bestComment,
                                                vm: vm)
            self.show(vc, sender: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension PostViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height
//        print("Offset: \(offset), ContentHeight: \(totalContentHeight), FixedHeight: \(totalScrollViewFixedHeight)")
        if offset >= (totalContentHeight - totalScrollViewFixedHeight) &&
            vm.queryDocumentSnapshot != nil &&
            !vm.isLoading
        {
            vm.fetchAdditionalPosts()
        }
    }
}
