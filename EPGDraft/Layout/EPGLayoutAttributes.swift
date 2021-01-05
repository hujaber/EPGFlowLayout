//
//  EPGLayoutAttributes.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 30/12/2020.
//

import UIKit

final class EPGLayoutAttributes: UICollectionViewLayoutAttributes {
    var initialOrigin: CGPoint = .zero
    
    override func copy(with zone: NSZone? = nil) -> Any {
        guard let copiedAttributes = super.copy(with: zone) as? EPGLayoutAttributes else {
            return super.copy(with: zone)
        }
        copiedAttributes.initialOrigin = initialOrigin
        return copiedAttributes
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherAttributes = object as? EPGLayoutAttributes else {
            return false
        }
        
        if otherAttributes.initialOrigin != initialOrigin {
            return false
        }
        
        return super.isEqual(object)
    }
}
