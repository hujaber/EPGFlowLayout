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
    
    private let itemOffset: CGFloat = 50
    
    private let itemHeight: CGFloat = 60
    
    var isSectionHeadersSticky: Bool = true
    
    var itemsShouldFloat: Bool = true
    
    private(set) lazy var timeHeaderItemSize: CGSize = .init(width: screenWidth - sectionHeaderSize!.width - itemOffset,
                                                             height: itemHeight)
    
    
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
        self.minimumLineSpacing = 2
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

