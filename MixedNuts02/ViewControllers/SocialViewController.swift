//
//  SocialViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import UIKit

class SocialViewController: BaseScrollViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navBarBottom: UIView!
    @IBOutlet weak var requestsTable: UITableView!
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var noRequestsBox: UIView!
    @IBOutlet weak var noFriendsBox: UIView!
    
    private let viewModel = SocialViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        
        requestsTable.register(UITableViewCell.self, forCellReuseIdentifier: "friend")
        requestsTable.delegate = self
        requestsTable.dataSource = self
        
        friendsTable.register(UITableViewCell.self, forCellReuseIdentifier: "friend")
        friendsTable.delegate = self
        friendsTable.dataSource = self
        
        // Do any additional setup after loading the view.
        navBarBottom.dropShadow()
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateFriends()
    }
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onRequestSent = { [weak self] in
            DispatchQueue.main.async {
                self?.searchField.text = ""
                self?.updateFriends()
            }
        }
        
        viewModel.onRequestUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateFriends()
            }
        }
        
        viewModel.onFriendshipUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.requestsTable.reloadData()
                self?.friendsTable.reloadData()
                self?.updateFriendsMessage()
                self?.updateRequestsMessage()
                if self?.viewModel.friendID != nil {
                    self?.selectTempFriend()
                }
            }
        }
        
        viewModel.onExistingFriend = { [weak self] in
            DispatchQueue.main.async {
                self?.showViewControllerAlert(title: "Existing Friend", message: "You already have a freindship with this user.")
            }
        }
        
        viewModel.onInvalidRequest = { [weak self] in
            DispatchQueue.main.async {
                self?.showViewControllerAlert(title: "Invalid Username", message: "No user with this name exists, please double check the value entered.")
            }
        }
        
        viewModel.onValidRequest = { [weak self] in
            DispatchQueue.main.async {
                self?.sendFriendRequest()
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                // Show error message (e.g., using an alert)
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    //MARK: - Data Reading & Writing
    func sendFriendRequest(){
        var friendships = [Friendship]()
        let toRequest = Friendship(uid: viewModel.friendID!, isSender: true, isPending: true)
        let fromRequest = Friendship(uid: AppUser.shared.uid!, isSender: false, isPending: true)
        
        friendships.append(toRequest)
        friendships.append(fromRequest)
        
        viewModel.sendRequest(friendships)
    }
    
    func acceptFriendRequest(_ friendId: String){
        viewModel.acceptRequests(friendId)
    }
    
    func deleteFriendRequest(_ friendId: String){
        viewModel.deleteRequests(friendId)
    }
    
    func updateFriends(){
        viewModel.fetchFriends()
    }
    
    func checkUsername(_ username: String) {
        viewModel.checkUserExists(username)
    }
    
    //MARK: - Button actions
    
    @IBAction func sendRequestTapped(_ sender: UIButton) {
        guard let username = searchField.text,
              !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            // Present an alert or handle empty fields appropriately
            showViewControllerAlert(title: "Empty Username", message: "Please enter a valid username.")
            return
        }
        
        checkUsername(username.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        // Dismiss the current view controller
        navigationController?.popViewController(animated: true)
    }

    //MARK: - Data Updating
    
    @IBAction func acceptRequestPressed(_ sender: UIButton) {
        if let requestView = sender.superview?.superview?.superview as? DesignableFriendRequestView?,
           let id = requestView?.friendObj!.uid{
            acceptFriendRequest(id)
        }
    }
    
    @IBAction func declineRequestPressed(_ sender: UIButton) {
        if let requestView = sender.superview?.superview?.superview as? DesignableFriendRequestView?,
           let id = requestView?.friendObj!.uid{
            deleteFriendRequest(id)
        }
    }
    
    func updateFriendsMessage(){
        if viewModel.friendsCollection.count == 0 {
            noFriendsBox.isHidden = false
        } else {
            noFriendsBox.isHidden = true
        }
    }
    
    func updateRequestsMessage(){
        if viewModel.requestsCollection.count == 0 {
            noRequestsBox.isHidden = false
        } else {
            noRequestsBox.isHidden = true
        }
    }
    
    
    //MARK: - Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 69 {
            return viewModel.requestsCollection.count
        } else if tableView.tag == 70 {
            return viewModel.friendsCollection.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath)
        cell.selectionStyle = .none
        if let viewWithTag = cell.contentView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        
        if tableView.tag == 69 {
            // otherwise, show regular task view
            let requestView = DesignableFriendRequestView.instanceFromNib(setFriend: viewModel.requestsCollection[indexPath.row], isTop: indexPath.row == 0, isBottom: indexPath.row == viewModel.requestsCollection.count - 1)
            requestView.translatesAutoresizingMaskIntoConstraints = false
            requestView.heightAnchor.constraint(equalToConstant: 81).isActive = true
            requestView.widthAnchor.constraint(equalToConstant: requestsTable.frame.width).isActive = true
            requestView.tag = 100
            requestView.acceptButton.removeTarget(nil, action: nil, for: .allEvents)
            requestView.acceptButton.addTarget(self, action: #selector(acceptRequestPressed(_:)), for: .touchUpInside)
            requestView.declineButton.removeTarget(nil, action: nil, for: .allEvents)
            requestView.declineButton.addTarget(self, action: #selector(declineRequestPressed(_:)), for: .touchUpInside)
            
            cell.contentView.addSubview(requestView)
            return cell
        } else if tableView.tag == 70 {
            // otherwise, show regular task view
            let friendView = DesignableFriendView.instanceFromNib(setFriend: viewModel.friendsCollection[indexPath.row], isTop: indexPath.row == 0, isBottom: indexPath.row == viewModel.friendsCollection.count - 1)
            friendView.translatesAutoresizingMaskIntoConstraints = false
            friendView.heightAnchor.constraint(equalToConstant: 81).isActive = true
            friendView.widthAnchor.constraint(equalToConstant: friendsTable.frame.width).isActive = true
            friendView.tag = 100
            cell.contentView.addSubview(friendView)
            return cell
        }
        
        return cell
    }
    
    //MARK: - New friend selection
    
    func selectTempFriend(){
        var count = 0
        for friend in viewModel.friendsCollection {
            if friend.uid == viewModel.friendID {
                let index = IndexPath(row: count, section: 0)
                friendsTable.selectRow(at: index, animated: true, scrollPosition: .middle)
                viewModel.friendID = nil
                return
            }
            count += 1
        }
    }
}
