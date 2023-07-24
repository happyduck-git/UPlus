//
//  TodayRankCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import UIKit
import Combine

final class TodayRankCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Dependency
    private var vm: RankingViewViewModel?

    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let rankTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray6
        // TODO: Register Custom Cell
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)

        return table
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure with View Model
extension TodayRankCollectionViewCell {
    func configure(with vm: RankingViewViewModel) {
        self.vm = vm
        vm.getUserRanking()
        self.bind(with: vm)
    }
}

// MARK: - Bind with View Model
extension TodayRankCollectionViewCell {
    private func bind(with vm: RankingViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        vm.$userList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                print("Reloaded...")
                self.rankTableView.reloadData()
            }
            .store(in: &bindings)
    }
}

// MARK: - Set UI & Layout
extension TodayRankCollectionViewCell {
    private func setUI() {
        self.contentView.addSubview(rankTableView)
    }
    
    private func setLayout() {
        self.rankTableView.frame = self.contentView.bounds
    }
    
    private func setDelegate() {
        self.rankTableView.delegate = self
        self.rankTableView.dataSource = self
    }
}

// MARK: - TableViw Delegate & DataSource
extension TodayRankCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = self.vm else { return 0 }
        return vm.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = self.vm else { fatalError() }
        let cellVM = vm.userList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = "\(cellVM.userNickname) -- Point: \(cellVM.userTotalPoint ?? 0)"
        cell.contentConfiguration = config
        return cell
    }
}
