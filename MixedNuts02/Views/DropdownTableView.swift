//
//  DropdownTableView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-23.
//

import UIKit

class DropdownTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var textField: DesignableUITextField!
    var scrollEnabled: Bool = true
    var options: [String] = ["Test"]
    
    var isCustomTimeDropdown = false
    var isCustomDayDropdown = false
    var dayObject: DaySchedule?
    var timePicker: UIDatePicker?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            backgroundColor = UIColor.white.withAlphaComponent(0.98) // Slightly transparent
            configureShadow()
            clipsToBounds = false
        }
    }
    
    func configureShadow(){
        layer.shadowColor = UIColor.black.cgColor // Shadow color
        layer.shadowOpacity = 0.2 // Shadow opacity
        layer.shadowOffset = CGSize(width: 0, height: 4) // Shadow offset
        layer.shadowRadius = 8 // Shadow blur radius
    }
    
    func configureTable(){
        tableView.rowHeight = 44
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = scrollEnabled
        tableView.layer.cornerRadius = cornerRadius
        tableView.clipsToBounds = true
    }
    
    //MARK: - Table view delegate
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        
        if (isCustomTimeDropdown && indexPath.row == 2){
            timePicker = UIDatePicker()
            timePicker?.preferredDatePickerStyle = .compact
            timePicker?.datePickerMode = .time
            timePicker?.alpha = 0.011
            timePicker?.translatesAutoresizingMaskIntoConstraints = false
            
            timePicker?.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
            
            let scaleTransform = CGAffineTransform(scaleX: 4, y: 4)
            let translationTransform = CGAffineTransform(translationX: 15, y: cell.frame.height + 10)
            let finalTransform = scaleTransform.concatenating(translationTransform)
            
            timePicker?.transform = finalTransform
            
            timePicker?.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
            
            cell.addSubview(timePicker!)
        }
        
        return cell
    }
    
    // UITableViewDelegate method to handle selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCustomTimeDropdown {
            if indexPath.row == 0 {
                let calendar = Calendar.current
                var dateComponents = DateComponents()
                dateComponents.hour = 23  // 11 PM
                dateComponents.minute = 59  // 59 minutes
                if let date = calendar.date(from: dateComponents) {
                    timePicker?.date = date
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    textField.text = formatter.string(from: date)
                }
            } else if indexPath.row == 1 {
                // CONFIGURE CLASS TIME HERE
                let calendar = Calendar.current
                var dateComponents = DateComponents()
                dateComponents.hour = 12  // 11 PM
                dateComponents.minute = 00  // 59 minutes
                if let date = calendar.date(from: dateComponents) {
                    timePicker?.date = date
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    textField.text = formatter.string(from: date)
                }
                

            }
        } 
        else {
            textField.text = options[indexPath.row]
            dayObject?.day = DayOfWeek(from: options[indexPath.row])
            
            /*
            // Animate selection
            guard let cell = tableView.cellForRow(at: indexPath) else { return }

            // Add animation on selection
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) // Shrink the cell a bit
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = CGAffineTransform.identity // Restore it to its original size
                }
            }
             */
        }
    }
    
    //MARK: - Table deselect
    func deselectAllCells() {
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    //MARK: - Picker to field
    
    @objc func timeChanged(_ sender: UIDatePicker) {
        // Format the date and set it to the text field
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        textField.text = formatter.string(from: sender.date)
        
        tableView.selectRow(at: IndexPath(row: 2, section: 0), animated: true, scrollPosition: .none)
    }
    
    //MARK: - View instantiation
    class func instanceFromNib(setOptions: [String], scrollEnabled: Bool) -> DropdownTableView{
        let dropdown = UINib(nibName: "DropdownTableView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DropdownTableView
        dropdown.scrollEnabled = scrollEnabled
        dropdown.options = setOptions
        dropdown.configureTable()
        return dropdown
    }
    
}
