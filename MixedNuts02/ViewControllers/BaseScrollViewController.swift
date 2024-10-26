//
//  BaseScrollViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-25.
//

import UIKit

class BaseScrollViewController: UIViewController {
    
    var baseScrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let scrollView = baseScrollView,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let activeTextField = view.findFirstResponder() else { return }
        
        let textFieldFrameInView = activeTextField.convert(activeTextField.bounds, to: scrollView)
        
        let keyboardHeight = keyboardFrame.height
        var textFieldBottom = 0.0
        
        if let textView = activeTextField as? UITextView {
            textFieldBottom = textFieldFrameInView.origin.y
        } else {
            textFieldBottom = textFieldFrameInView.origin.y + textFieldFrameInView.height
        }
        
        let visibleHeight = scrollView.frame.height - keyboardHeight
        
        if textFieldBottom > visibleHeight {
            let inset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            scrollView.contentInset = inset
            scrollView.scrollIndicatorInsets = inset
            
            let offsetY = textFieldBottom - visibleHeight
            scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let scrollView = baseScrollView else { return }
        UIView.animate(withDuration: 0.3) {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
        }
    }
    
    deinit {
        // Remove observers when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
}
