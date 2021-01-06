//
//  ViewController.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 28/12/2020.
//

import UIKit

struct EPGProgram {
    var startDate: Date
    var endDate: Date

    
    static func anotherFactory() -> [[EPGProgram]] {
        let startDate = Date()
        let numberOfSections = 9
        let array = (0..<numberOfSections).map { index -> EPGProgram in
//            if Bool.random() {
                return EPGProgram(startDate: startDate.addingTimeInterval(Double(index) *  Double(Int.random(in: 1...2) * 1800)),
                                  endDate: startDate.addingTimeInterval(Double(index).advanced(by: 1) * Double(Int.random(in: 1...2)) * 1800))
//            } else if Bool.random() {
//                return EPGProgram(startDate: startDate.addingTimeInterval(Double(index) * 3700),
//                                  endDate: startDate.addingTimeInterval(Double(index).advanced(by: 1) * 2000))
//            } else {
//                return EPGProgram(startDate: startDate.addingTimeInterval(Double(index) * 3600),
//                                  endDate: startDate.addingTimeInterval(Double(index).advanced(by: 1) * 2000))
//            }
        }.shuffled().map {
            [$0, $0, $0, $0, $0, $0, $0].shuffled()
        }
        
        return array.shuffled()
    }
}


class ViewController: UIViewController {
    
    private lazy var flowLayout = EPGFlowLayout().with {
        $0.dataSource = self
    }
        
    private lazy var programs: [[EPGProgram]] = EPGProgram.anotherFactory()
    
    private var collectionContentOffsetObserver: NSKeyValueObservation?
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).with {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.register(SectionHeaderCell.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: String(describing: SectionHeaderCell.self))
        $0.register(ProgramCell.self, forCellWithReuseIdentifier: ProgramCell.identifier)
        $0.register(TimeHeaderCell.self, forSupplementaryViewOfKind: EPGFlowLayout.Element.timeHeader.kind,
                    withReuseIdentifier: TimeHeaderCell.identifier)
        $0.bounces = false
        $0.maximumZoomScale = 1
        collectionContentOffsetObserver = $0.observe(\.contentOffset, changeHandler: { (collectionView, value) in
            let newValue = collectionView.contentOffset.x + 80
            let stringValue = String(Int(newValue))
            self.contentOffSetLabel.text = stringValue
            
        })
    }
    
    private lazy var contentOffSetLabel: UILabel = UILabel().with {
        $0.textColor = .blue
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 17, weight: .heavy)
        $0.text = "TEST"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.addSubview(contentOffSetLabel)
        NSLayoutConstraint.activate([
            contentOffSetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentOffSetLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
        collectionView.reloadData()
    }
}

extension ViewController: EPGFlowLayoutDataSource {
    func collectionView(_ collectionView: UICollectionView, startDateAtIndexPath indexPath: IndexPath) -> Date {
        programs[indexPath.section][indexPath.item].startDate
    }
    
    func collectionView(_ collectionView: UICollectionView, endDateAtIndexPath indexPath: IndexPath) -> Date {
        programs[indexPath.section][indexPath.item].endDate
    }
    
    
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        programs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        programs[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: ProgramCell.identifier,
                                 for: indexPath) as! ProgramCell
        cell.populate(indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView
                .dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                  withReuseIdentifier: String(describing: SectionHeaderCell.self),
                                                  for: indexPath) as! SectionHeaderCell
            return headerView
        } else if kind == EPGFlowLayout.Element.timeHeader.kind {
            let headeView = collectionView.dequeueReusableSupplementaryView(ofKind: EPGFlowLayout.Element.timeHeader.kind,
                                                                            withReuseIdentifier: TimeHeaderCell.identifier,
                                                                            for: indexPath) as! TimeHeaderCell
            return headeView
        }
        return .init()
    }
    
    
}



