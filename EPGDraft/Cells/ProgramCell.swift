//
//  ProgramCell.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 30/12/2020.
//

import UIKit

final class ProgramCell: UICollectionViewCell {
    
    lazy var firstView = UILabel().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    static var identifier: String {
        String(describing: Self.self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 0.5
        contentView.addSubview(firstView)
//        backgroundColor = UIColor(red: 0.22, green: 0.25, blue: 0.25, alpha: 1.00)
        NSLayoutConstraint.activate([
            firstView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            firstView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            firstView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            firstView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func populate(indexPath: IndexPath) {
        firstView.text = "Item at row: \(indexPath.item), section: \(indexPath.section)"
        backgroundColor = Bool.random() ? .black : UIColor(red: 0.22, green: 0.25, blue: 0.25, alpha: 1.00)
    }
    
    func populate(item: EPGProgram) {
        firstView.text = "Lenght: \(item.durationInMinutes) minutes"
        backgroundColor = Bool.random() ? .black : UIColor(red: 0.22, green: 0.25, blue: 0.25, alpha: 1.00)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
