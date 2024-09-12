//
//  DesignableTaskCountView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-08.
//

import UIKit

class DesignableTaskCountView: UIView {
    //MARK: - Task View customization
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var taskCount: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                clipsToBounds = true
            }
        }
    
    @IBInspectable var bkgColor: UIColor = UIColor.lightGray {
        didSet {
        }
    }
    
    @IBInspectable var doneColor: UIColor = UIColor.lightGray {
        didSet{
        }
    }

    func updateView() {

    }
    
    func updateCount(){
        if taskCount?.text == "0" {
            self.backgroundColor = doneColor
        } else {
            self.backgroundColor = bkgColor
        }
    }

}
