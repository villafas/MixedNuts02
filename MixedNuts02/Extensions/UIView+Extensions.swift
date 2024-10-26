//
//  UIView+Extensions.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-10.
//

import Foundation
import UIKit

extension UIView {
    func dropShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 2
        layer.masksToBounds = false
    }
    
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

protocol ChildViewDelegate: AnyObject {
    func showAlert(title: String, message: String)
}
