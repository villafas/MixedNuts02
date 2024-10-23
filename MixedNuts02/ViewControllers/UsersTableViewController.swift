//
//  UsersTableViewController.swift
//  MixedNuts02
//
//  Created by Gavin Shaw on 2024-09-16.


import Foundation
import UIKit

class UsersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    // Array to store fetched users
    @IBOutlet weak var searchField: DesignableUITextField!
    @IBOutlet weak var tableView: SelfSizedTableView!
    
    var users = [FriendUser]()
    var filteredUsers: [FriendUser] = [] // Users after the search function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchField.delegate = self // Set the text field delegate here
        
        // Register a basic UITableViewCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        
        fetchUsers()
        
        //Hiding the users when loading in
        filteredUsers = []
        tableView.reloadData()
            
    }

    // MARK: - Search Users on Button Press (Exact Match)
    @IBAction func searchButtonTapped(_ sender: Any) {
        guard let searchText = searchField.text?.lowercased(), !searchText.isEmpty else {
            // If search field is empty, show all users
            filteredUsers = []
            tableView.reloadData()
            return
        }

        // Filter users based on the exact match of displayName or email
        filteredUsers = users.filter { user in
            let displayName = user.displayName?.lowercased() ?? ""
            let email = user.email?.lowercased() ?? ""
            return displayName == searchText || email == searchText
        }

        tableView.reloadData() // Refresh the table view with filtered users
    }

    // MARK: - Fetch Users
    func fetchUsers() {
        // Use FirebaseManager to fetch users
        FirebaseManager.shared.fetchUsers { [weak self] result in
            switch result {
            case .success(let fetchedUsers):
                self?.users = fetchedUsers // Store fetched users
                DispatchQueue.main.async {
                    self?.tableView.reloadData() // Reload table view with new data
                }
            case .failure(let error):
                print("Failed to fetch users: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Table View Data Source Methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredUsers.count // show filter users only and not everyone
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
            
            // If filtered users is not empty, display filtered users
            let user = filteredUsers.isEmpty ? users[indexPath.row] : filteredUsers[indexPath.row]
            
            cell.textLabel?.text = user.displayName // Display user's name
            cell.detailTextLabel?.text = user.email // Display user's email
            
            
            //remove "Request Send" overlay button
            for subview in cell.contentView.subviews where subview is UIButton {
                subview.removeFromSuperview()
            }
            
            // Create "Add Friend" button
            let sendRequestButton = UIButton(type: .system)
            sendRequestButton.setTitle("Add Friend", for: .normal)
            sendRequestButton.frame = CGRect(x: tableView.frame.width - 120, y: 5, width: 100, height: 30) // Adjust as necessary
            sendRequestButton.tag = indexPath.row // Store the index to know which user to send request to
            sendRequestButton.addTarget(self, action: #selector(sendFriendRequestTapped(_:)), for: .touchUpInside)
            
            // Add the button to the cell's content view
            cell.contentView.addSubview(sendRequestButton)
            
            return cell
        }

        // MARK: - Send Friend Request Action
        @objc func sendFriendRequestTapped(_ sender: UIButton) {
            let userIndex = sender.tag // Get the index of the user based on the button's tag
            let selectedUser = filteredUsers[userIndex] // Get the selected user

            // Call FirebaseManager to send the friend request
            FirebaseManager.shared.sendFriendRequest(from: AppUser.shared.uid!, to: selectedUser.uid!) { result in
                switch result {
                case .success:
                    print("Friend request sent to \(selectedUser.displayName!)")

                    // Update the button title and disable it to show request was sent
                    DispatchQueue.main.async {
                        sender.setTitle("Request Sent", for: .normal)
                        sender.isEnabled = false
                        sender.setTitleColor(.gray, for: .normal) // Optional: Make the button text gray
                    }

                case .failure(let error):
                    print("Failed to send friend request: \(error.localizedDescription)")
                }
            }
    }
}
