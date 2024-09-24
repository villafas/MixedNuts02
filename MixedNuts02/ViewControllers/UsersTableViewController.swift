//
//  UsersTableViewController.swift
//  MixedNuts02
//
//  Created by Gavin Shaw on 2024-09-16.
//

import Foundation
import UIKit



class UsersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {   // Array to store fetched users
    
    
    @IBOutlet weak var searchField: DesignableUITextField!
    @IBOutlet weak var tableView: SelfSizedTableView!
    
    var users = [FriendUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register a basic UITableViewCell (if not using a storyboard prototype cell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendTitle")
        
        // Fetch users from Firebase
        fetchUsers()
    }
    
    // MARK: - Fetch Users
    //Gavin Shaw - Sept  16 th
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
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        
    }
    
    
    // MARK: - Table View Data Source Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.displayName // Display user's name
        cell.detailTextLabel?.text = user.email // Display user's email
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // section title
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendTitle")
        
        cell?.textLabel!.text = "Friend List"
        return cell
    }
    

}
