//
//  DesignableFriendAcceptView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import Foundation

import UIKit

class DesignableFriendRequestView: DesignableFriendView {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    //MARK: - Expanded task view instantiation
    override class func instanceFromNib(setFriend: FriendUser, isTop: Bool = false, isBottom: Bool = false) -> DesignableFriendRequestView{
        let friend = UINib(nibName: "FriendRequestView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableFriendRequestView
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
