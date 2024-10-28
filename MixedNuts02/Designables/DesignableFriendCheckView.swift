//
//  DesignableFriendCheckView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import Foundation
import UIKit

class DesignableFriendCheckView: DesignableFriendView {
    
    @IBOutlet weak var checkBox: UIImageView!
    
    func updateImage(_ isSelected: Bool) {
        checkBox.image = UIImage(named: isSelected ? "checkBox" : "checkBoxUnchecked")
    }
    
    
    //MARK: - Expanded task view instantiation
    override class func instanceFromNib(setFriend: FriendUser, isTop: Bool = false, isBottom: Bool = false) -> DesignableFriendCheckView{
        let friend = UINib(nibName: "FriendCheckView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableFriendCheckView
        friend.friendObj = setFriend
        friend.fullName.text = "\(setFriend.firstName) \(setFriend.lastName)"
        friend.username.text = "\(setFriend.username)"
        
        if isTop {
            friend.topDivider.isHidden = true
        }
        
        if isBottom {
            friend.bottomDivider.isHidden = true
        }
        
        return friend
    }

}
