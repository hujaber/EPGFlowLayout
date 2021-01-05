//
//  TimeHeaderCell.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 05/01/2021.
//

import UIKit

final class TimeHeaderCell: UICollectionReusableView {
    
    static var identifier: String {
        String(describing: Self.self)
    }
    
    var time: Date?
    let label = UILabel().with {
        $0.textColor = .init(white: 155/255, alpha: 1.0)
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
        label.text = "10:00AM"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
