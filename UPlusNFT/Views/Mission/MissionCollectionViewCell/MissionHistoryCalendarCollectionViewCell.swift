//
//  MissionHistoryCalendarCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/25.
//

import UIKit
import FSCalendar
import Combine

protocol MissionHistoryCalendarCollectionViewCellDelegate: AnyObject {
    func dateSelected(_ date: Date)
}

final class MissionHistoryCalendarCollectionViewCell: UICollectionViewCell {
    
    private var vm: MyPageViewViewModel?
    
    // MARK: - Delegate
    weak var delegate: MissionHistoryCalendarCollectionViewCellDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let calendar: FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        calendar.backgroundColor = .white
        calendar.clipsToBounds = true
        
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerDateFormat = "M월"
        calendar.appearance.weekdayTextColor = .systemGray
        calendar.firstWeekday = 1
        calendar.locale = Locale.init(identifier: "en")
        
        let numOfDays = calendar.calendarWeekdayView.weekdayLabels.count
        calendar.calendarWeekdayView.weekdayLabels[numOfDays - 2].textColor = UPlusColor.mint
        calendar.calendarWeekdayView.weekdayLabels[numOfDays - 1].textColor = UPlusColor.mint
        calendar.placeholderType = .none
        calendar.appearance.todayColor = UPlusColor.mint
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .systemGray6
        self.setUI()
        self.setLayout()
        
        self.calendar.delegate = self
        self.calendar.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure
extension MissionHistoryCalendarCollectionViewCell {
    func bind(with vm: MyPageViewViewModel) {
        
        self.vm = vm
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        self.vm?.mission.$missionDates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                guard let `self` = self else { return }
                self.calendar.reloadData()
            }
            .store(in: &bindings)
        
    }
}

// MARK: - Set UI & Layout
extension MissionHistoryCalendarCollectionViewCell {
    private func setUI() {
        self.contentView.addSubview(calendar)
        self.calendar.layer.cornerRadius = 10
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.calendar.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.calendar.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.calendar.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.calendar.bottomAnchor, multiplier: 1)
        ])
        
        
    }
}

extension MissionHistoryCalendarCollectionViewCell: FSCalendarDelegate, FSCalendarDelegateAppearance, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.delegate?.dateSelected(date)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let missionDates = self.vm?.mission.missionDates ?? []
        
        if missionDates.contains(date.localDate().yearMonthDateFormat) {
            return 1
        } else {
            return 0
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return [UPlusColor.mint]
    }
}

