//
//  UIViewController+Extensions.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-04.
//

import Foundation
import UIKit

// Put this piece of code anywhere you like
extension UIViewController {
    // allow keyboards to be tapped out of
    
    //MARK: - Keyboard dismissal
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
