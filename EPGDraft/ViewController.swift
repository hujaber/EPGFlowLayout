//
//  ViewController.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 28/12/2020.
//

import UIKit

var items: [[EPGProgram]] {
    let startDate = Date()
    let halfHourSeconds: Double = 1800
    let twentyFiveMinutes: Double = 1800 - (5 * 60)
    let anHour: Double = 1800 * 2
    let anHourAnd15: Double = 3600 + (60 * 15)
    let fourtyFiveMinutes: Double = 60 * 45

    var firstSection = [EPGProgram]()
    for index in 0...5 {
        switch index {
        case 0:
            firstSection.append(.init(startDate: startDate,
                                      endDate: startDate.addingTimeInterval(twentyFiveMinutes)))
        case 1:
            firstSection.append(.init(startDate: firstSection[index - 1].endDate,
                                      endDate: firstSection[index - 1].endDate.addingTimeInterval(fourtyFiveMinutes)))
        case 2:
            firstSection.append(.init(startDate: firstSection[index - 1].endDate,
                                      endDate: firstSection[index - 1].endDate.addingTimeInterval(twentyFiveMinutes)))
        case 3:
            firstSection.append(.init(startDate: firstSection[index - 1].endDate,
                                      endDate: firstSection[index - 1].endDate.addingTimeInterval(anHour)))
        case 4:
            firstSection.append(.init(startDate: firstSection[index - 1].endDate,
                                      endDate: firstSection[index - 1].endDate.addingTimeInterval(anHourAnd15)))
        default:
            break
        }
        
    }
    
    return [firstSection, firstSection, firstSection.shuffled(), firstSection.shuffled(), firstSection.shuffled(),
            firstSection.shuffled(), firstSection.shuffled(), firstSection, firstSection.shuffled(),
            firstSection.reversed(), firstSection, firstSection, firstSection]
}

struct EPGProgram {
    var startDate: Date
    var endDate: Date

    
    var durationInMinutes: Double {
        let end = endDate.timeIntervalSince1970
        let start = startDate.timeIntervalSince1970
        let diff = end - start
        let inMinutes = diff / 60
        return inMinutes
    }
    
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
        
    private lazy var programs: [[EPGProgram]] = items
    
    
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
//        cell.populate(indexPath: indexPath)
        cell.populate(item: programs[indexPath.section][indexPath.item])
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



