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
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .large
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let rankTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray6
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false

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
        
        self.spinner.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure with View Model
extension TodayRankCollectionViewCell {
    func configure(with vm: RankingViewViewModel) {
        self.vm = vm
        self.bind(with: vm)
    }
}

// MARK: - Bind with View Model
extension TodayRankCollectionViewCell {
    private func bind(with vm: RankingViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        vm.$totakRankerFetched
            .receive(on: RunLoop.current)
            .sink { [weak self] in
                guard let `self` = self else { return }
                if $0 {
                    Task {
                        try await vm.getTodayRankers(totalRankerList: vm.totalRankerList)
                        try await vm.getYesterdayRankers(totalRankerList: vm.totalRankerList)
                        vm.getRanking()
                    }
                    
                }
            }
            .store(in: &bindings)
        
        vm.$todayRankerList
            .receive(on: DispatchQueue.main)
            .dropFirst(1)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
      
                self.rankTableView.reloadData()
                self.spinner.stopAnimating()
            }
            .store(in: &bindings)
        
        // TODO: Header로 옮기기
        vm.$yesterdayRankerList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                // TODO: TableView Header에 표시 필요.
                print("어제 랭커 " + ($0.first?.userEmail ?? "없음"))
            }
            .store(in: &bindings)
    }
}

// MARK: - Set UI & Layout
extension TodayRankCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.rankTableView,
                                     self.spinner)
    }
    
    private func setLayout() {
        self.rankTableView.frame = self.contentView.bounds
        self.spinner.frame = self.contentView.bounds
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
        return vm.todayRankerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = self.vm else { fatalError() }
        let cellVM = vm.todayRankerList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        var config = cell.defaultContentConfiguration()
        
        config.text = "#\(indexPath.row + 1)위 -- \(cellVM.userNickname) -- Point: \(cellVM.userPointHistory?.first?.userPointCount ?? 0)"
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.rankTableView.frame.width, height: 100.0))
        footer.backgroundColor = .white
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
}
