//
//  EPGLayoutSettings.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 30/12/2020.
//

import UIKit

struct EPGLayoutSettings {
    
    var startDate: Date
    var endDate: Date
    
    // Sizes
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    let itemOffset: CGFloat = 65
    
    private let itemHeight: CGFloat = 70
    
    var isSectionHeadersSticky: Bool = true
    
    var itemsShouldFloat: Bool = true
    
    private(set) lazy var timeHeaderItemSize: CGSize = .init(width: screenWidth - sectionHeaderSize!.width - itemOffset,
                                                             height: 40)
    
    var numberOfTimeHeaderItems: Int {
        let startDateInSeconds = startDate.timeIntervalSince1970
        let endDateInSeconds = endDate.timeIntervalSince1970
        let durationInSeconds = (endDateInSeconds - startDateInSeconds)
        let durationInMinutes = durationInSeconds / 60
        let halfHourPeriods = durationInMinutes / 30
        let numberOfTimeHeaderItems = halfHourPeriods + 1
        return Int(numberOfTimeHeaderItems)
    }
    
    var itemSize: CGSize {
        let sectionWidth = sectionHeaderSize!.width
        return .init(width: screenWidth - sectionWidth - itemOffset,
                     height: itemHeight)
    }
    var fullItemSize: CGSize {
        let sectionWidth = sectionHeaderSize!.width
        return .init(width: screenWidth - sectionWidth,
                     height: itemHeight)
    }
    
    var sectionHeaderSize: CGSize?
    
    // spacing
    var minimumInteritemSpacing: CGFloat
    var minimumLineSpacing: CGFloat
}

extension EPGLayoutSettings {
    init() {
        self.sectionHeaderSize = .init(width: 80, height: itemHeight)
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.startDate = .init()
        self.endDate = Date().endOfDay
    }
}



extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}

