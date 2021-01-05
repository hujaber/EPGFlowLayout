//
//  Withable.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 30/12/2020.
//

import Foundation

protocol Withable {
    associatedtype T
    
    @discardableResult func with(_ closure: (_ instance: T) -> Void) -> T
}

extension Withable {
    @discardableResult func with(_ closure: (_ instance: Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Withable {}

