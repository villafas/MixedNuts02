//
//  SignUpViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import Foundation

class SignUpViewModel {
    
    //MARK: - Variables
    
    private let firebaseManager = FirebaseManager.shared
    
    var errorMessage: String?

    var onSignUp: (() -> Void)?
    var onTakenUsername: (() -> Void)?
    var onError: ((String) -> Void)?
    
    
    //MARK: - Methods
    func checkUsername(_ username: String) {
        FirebaseManager.shared.isUsernameTaken(username){ [weak self] result in
            switch result {
            case .success(let isTaken):
                if isTaken {
                    self?.onTakenUsername?()
                } else {
                    self?.onSignUp?()
                }
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
            }
        }
    }
}
