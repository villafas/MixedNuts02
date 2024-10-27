//
//  DesignableFriendView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import UIKit

class DesignableFriendView: UIView {
    //MARK: - Friend View customization
    
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var topDivider: UIView!
    @IBOutlet weak var bottomDivider: UIView!
    @IBOutlet weak var pendingIcon: UIImageView?
    
    
    var friendObj: FriendUser?
    
    func updateView() {

    }
    
    //MARK: - Expanded task view instantiation
    class func instanceFromNib(setFriend: FriendUser, isTop: Bool = false, isBottom: Bool = false) -> DesignableFriendView{
        let friend = UINib(nibName: "FriendView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableFriendView
        friend.friendObj = setFriend
        friend.fullName.text = "\(setFriend.firstName) \(setFriend.lastName)"
        friend.username.text = "\(setFriend.username)"
        if !friend.friendObj!.isPending! {
            friend.pendingIcon?.isHidden = true
        }
        
        if isTop {
            friend.topDivider.isHidden = true
        }
        
        if isBottom {
            friend.bottomDivider.isHidden = true
        }
        
        return friend
    }

}
