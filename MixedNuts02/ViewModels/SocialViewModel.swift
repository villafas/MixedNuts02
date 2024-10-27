//
//  SocialViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import Foundation

class SocialViewModel {
    
    //MARK: - Variables
    
    private let firebaseManager = FirebaseManager.shared
    
    var friendsCollection = [FriendUser]()
    var requestsCollection = [FriendUser]()
    
    var friendID: String?
    
    var errorMessage: String?
    var canSendRequest: Bool = false

    var onRequestSent: (() -> Void)?
    var onRequestUpdated: (() -> Void)?
    var onFriendshipUpdated: (() -> Void)?
    var onExistingFriend: (() -> Void)?
    var onInvalidRequest: (() -> Void)?
    var onValidRequest: (() -> Void)?
    var onError: ((String) -> Void)?
    
    //MARK: - Methods
    func checkUserExists(_ username: String) {
        if let foundFriend = friendsCollection.first(where: { $0.username == username }) ??
            requestsCollection.first(where: { $0.username == username }) {
            onExistingFriend?()
            return
        }
        
        FirebaseManager.shared.checkUserExists(username){ [weak self] result in
            switch result {
            case .success(let userId):
                if let uid = userId, uid != AppUser.shared.uid {
                    self?.friendID = uid
                    self?.onValidRequest?()
                } else {
                    self?.onInvalidRequest?()
                }
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
            }
        }
    }
    
    func sendRequest(_ requests: [Friendship]) {
        FirebaseManager.shared.sendRequest(requests){ [weak self] result in
            switch result {
            case .success():
                self?.onRequestSent?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
            }
        }
    }
    
    func acceptRequests(_ friendId: String){
        FirebaseManager.shared.acceptFriendRequests(friendId){ [weak self] result in
            switch result {
            case .success():
                self?.onRequestUpdated?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
            }
        }
    }
    
    func deleteRequests(_ friendId: String){
        FirebaseManager.shared.deleteFriendRequests(friendId){ [weak self] result in
            switch result {
            case .success():
                self?.onRequestUpdated?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
            }
        }
    }
    
    func fetchFriends() {
        firebaseManager.fetchFriends() { [weak self] result in
            switch result {
            case .success(let fetchedFriends):
                self?.friendsCollection = [FriendUser]()
                self?.requestsCollection = [FriendUser]()
                // Arrange tasks in proper sections
                for friendship in fetchedFriends {
                    self?.firebaseManager.fetchFriendDetails(friendship) { [weak self] result in
                        switch result {
                        case .success(let friendDetails):
                            if friendship.isPending {
                                if friendship.isSender {
                                    self?.friendsCollection.append(friendDetails)
                                } else {
                                    self?.requestsCollection.append(friendDetails)
                                }
                            } else {
                                self?.friendsCollection.append(friendDetails)
                            }
                            if fetchedFriends.count == (self?.friendsCollection.count)! + (self?.requestsCollection.count)! {
                                self?.canSendRequest = true
                            }
                            self?.onFriendshipUpdated?()  // Notify the view controller to update the UI
                        case .failure(let error):
                            self?.errorMessage = error.localizedDescription
                            self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
                        }
                    }
                }
                if fetchedFriends.count == 0 {
                    self?.canSendRequest = true
                    self?.onFriendshipUpdated?()
                }
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
}
