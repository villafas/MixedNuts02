//
//  BadgesViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-04-18.
//

import UIKit

class BadgesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Collection view delegate
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 4
    }

    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //MARK: - We need to conform this cell of UICollectionView to our prototype cell which is CollectionViewCell
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Badge", for: indexPath) as! BadgeCollectionViewCell
        
        // Hard code values until further development
        if (indexPath.row == 0){
            cell.number.text = "10"
            cell.title.text = "Tasks Completed"
        } else if (indexPath.row == 1){
            cell.number.text = "5"
            cell.title.text = "Tasks Deleted"
        } else if (indexPath.row == 2){
            cell.number.text = "3"
            cell.title.text = "Single Day Record"
        } else if (indexPath.row == 3){
            cell.number.text = "April 2nd"
            cell.number.font = cell.number.font.withSize(22)
            cell.title.text = "First Task Completed"
        }
    
        return cell
    }
    
    //MARK: - Collection view size 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/2.1, height: UIScreen.main.bounds.height/3)
        }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
