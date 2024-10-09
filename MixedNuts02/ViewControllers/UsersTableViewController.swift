//
//  UsersTableViewController.swift
//  MixedNuts02
//
//  Created by Gavin Shaw on 2024-09-16.
//

import Foundation
import UIKit

class UsersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    // Array to store fetched users
    @IBOutlet weak var searchField: DesignableUITextField!
    @IBOutlet weak var tableView: SelfSizedTableView!
    
    var users = [FriendUser]()
    var filteredUsers: [FriendUser]=[] //Users after the search function
    
    
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        // Register a basic UITableViewCell (if not using a storyboard prototype cell)
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendTitle")
//        
//        // Fetch users from Firebase
//        fetchUsers()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchField.delegate = self // Set the text field delegate here
        
        // Register a basic UITableViewCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        
        fetchUsers()
    }

    // Implement UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchUsers(text: textField.text ?? "")
        return true
    }

    // Update your search logic here
    func searchUsers(text: String) {
        let searchText = text.lowercased()
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { user in
                let displayName = user.displayName?.lowercased() ?? ""
                let email = user.email?.lowercased() ?? ""
                return displayName.contains(searchText) || email.contains(searchText)
            }
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Fetch Users
    //Gavin Shaw - Sept  16th
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
    
    
    //MARK: - Search Users
    // Known Error handing - eg:filesystem, permissions (user related )
    @IBAction func searchButtonTapped(_ sender: Any) {
        
                guard let searchText = searchField.text?.lowercased(), !searchText.isEmpty else {
                    // If search field is empty, show all users
                    filteredUsers = users
                    tableView.reloadData()
                    return
                }
        
                // Filter users based on the search text (matching displayName or email)
                filteredUsers = users.filter { user in
                    let displayName = user.displayName?.lowercased() ?? ""
                    let email = user.email?.lowercased() ?? ""
                    return displayName.contains(searchText) || email.contains(searchText)
                }
        
                tableView.reloadData() // Refresh the table view with filtered users
            }
        
  
    
    // MARK: - Table View Data Source Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.isEmpty ? users.count : filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        
        // If filtered users is not empty, display filtered users
        let user = filteredUsers.isEmpty ? users[indexPath.row] : filteredUsers[indexPath.row]
        
        cell.textLabel?.text = user.displayName // Display user's name
        cell.detailTextLabel?.text = user.email // Display user's email
        return cell
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        // section title
//        let cell = tableView.dequeueReusableCell(withIdentifier: "friendTitle")
//        
//        cell?.textLabel!.text = "Friend List"
//        return cell
//    }
    }




