//
//  ShareTaskViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-27.
//

import Foundation

class ShareTaskViewModel {
    
    //MARK: - Variables
    
    private let firebaseManager = FirebaseManager.shared
    
    var friendsCollection = [FriendUser]()
    
    var errorMessage: String?
    var canSendTask: Bool = false

    var onFriendsUpdated: (() -> Void)?
    var onTaskSent: (() -> Void)?
    var onError: ((String) -> Void)?
    
    //MARK: - Methods
    
    func shareTask(_ chosenFriends: [IndexPath], _ taskObj: Task) {
        for friend in chosenFriends {
            let friendObj = friendsCollection[friend.row]
            var newTask = taskObj
            newTask.id = AppUser.shared.uid!
            
            FirebaseManager.shared.shareTask(newTask, friendObj.uid) { [weak self] result in
                switch result {
                case .success():
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
                }
            }
        }
        onTaskSent?()
    }
    
    func fetchFriends() {
        firebaseManager.fetchFriends() { [weak self] result in
            switch result {
            case .success(let fetchedFriends):
                self?.friendsCollection = [FriendUser]()
                // Arrange tasks in proper sections
                for friendship in fetchedFriends {
                    self?.firebaseManager.fetchFriendDetails(friendship) { [weak self] result in
                        switch result {
                        case .success(let friendDetails):
                            if !friendship.isPending {
                                self?.friendsCollection.append(friendDetails)
                            }
                            self?.onFriendsUpdated?()  // Notify the view controller to update the UI
                        case .failure(let error):
                            self?.errorMessage = error.localizedDescription
                            self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
                        }
                    }
                }
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
}
