//
//  SectionHeaderCell.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 30/12/2020.
//

import UIKit


final class SectionHeaderCell: UICollectionReusableView  {
    
    private lazy var imageView = UIImageView().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.image = UIImage(named: "sportsMaxLogo")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInterface()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInterface()
    }
    
    private func setupInterface() {
        self.backgroundColor = .darkGray
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
