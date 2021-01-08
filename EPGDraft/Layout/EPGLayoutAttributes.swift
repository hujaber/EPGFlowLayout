//
//  EPGLayoutAttributes.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 30/12/2020.
//

import UIKit

final class EPGLayoutAttributes: UICollectionViewLayoutAttributes {
    var initialOrigin: CGPoint = .zero
  //  var isFullWidth: Bool = true

    
    override func copy(with zone: NSZone? = nil) -> Any {
        guard let copiedAttributes = super.copy(with: zone) as? EPGLayoutAttributes else {
            fatalError()
        }
        copiedAttributes.initialOrigin = initialOrigin
     //   copiedAttributes.isFullWidth = isFullWidth
        return copiedAttributes
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherAttributes = object as? EPGLayoutAttributes else {
            return false
        }
        
        if otherAttributes.initialOrigin != initialOrigin {
            return false
        }
        
//        if otherAttributes.isFullWidth != isFullWidth {
//            return false
//        }
        
        return super.isEqual(object)
    }
}
