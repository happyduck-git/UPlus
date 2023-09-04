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

        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: UITableViewCell.identifier)
        
        table.register(NoRankTableViewCell.self,
                       forCellReuseIdentifier: NoRankTableViewCell.identifier)
        
        table.register(YesterdayRankerTableViewCell.self,
                       forCellReuseIdentifier: YesterdayRankerTableViewCell.identifier)
        
        table.register(TodayRankTableViewCell.self,
                       forCellReuseIdentifier: TodayRankTableViewCell.identifier)
        
        return table
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UPlusColor.grayBackground
        
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
        
        vm.$totalRankerFetched
            .receive(on: RunLoop.current)
            .sink {
                
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
        
        vm.$yesterdayRankerList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                
                self.rankTableView.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let vm = self.vm else { return 0 }
        
        if vm.todayRankerList.isEmpty {
            return 1
        } else {
            return vm.todayRankSections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = self.vm else { return 0 }
        
        if vm.todayRankerList.isEmpty {
            return 1
        } else {
            switch section {
            case 0:
                return 1
                
            default:
                return vm.todayRankerList.count
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vm = self.vm else { return UITableViewCell() }
        
        if vm.todayRankerList.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoRankTableViewCell.identifier, for: indexPath) as? NoRankTableViewCell else {
                return UITableViewCell()
            }
            
            return cell
            
        } else {
            switch indexPath.section {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: YesterdayRankerTableViewCell.identifier, for: indexPath) as? YesterdayRankerTableViewCell else {
                    return UITableViewCell()
                }
                cell.selectionStyle = .none
                
                let ranker = vm.yesterdayRankerList.first
                let userIndex = ranker?.userIndex ?? 0
                let topNft = vm.topNfts[userIndex]
                
                cell.configure(ranker: ranker, doc: topNft)
                return cell
                
            default:
                let cellVM = vm.todayRankerList[indexPath.row]
                let topNft = vm.topNfts[cellVM.userIndex]
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TodayRankTableViewCell.identifier, for: indexPath) as? TodayRankTableViewCell else {
                    return UITableViewCell()
                }
                cell.resetCell()
                
                switch indexPath.item {
                case 0, 1, 2:
                    cell.configureTop3(with: cellVM, doc: topNft, at: indexPath.row)
                default:
                    cell.configureOthers(with: cellVM, doc: topNft, at: indexPath.row)
                }
                
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let vm = self.vm else { return 0.0 }
        
        if vm.todayRankerList.isEmpty {
            return self.contentView.frame.height
        } else {
            if indexPath.section == 0 {
                return 152
            } else {
                return 60
            }
        }
    }
    
}

//MARK: - Footer
extension TodayRankCollectionViewCell {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let vm = self.vm else { return nil }
        
        if vm.todayRankerList.isEmpty {
            return nil
        } else {
            if section == 1 {
                let footer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.rankTableView.frame.width, height: 50.0))
                footer.backgroundColor = .white
                return footer
            } else {
                return nil
            }
        }

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let vm = self.vm else { return 0 }
        
        if vm.todayRankerList.isEmpty {
            return 0
        } else {
            if section == 1 {
                return 100
            } else {
                return 0
            }
        }

    }
}
