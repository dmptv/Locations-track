//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by 123 on 03.12.17.
//  Copyright © 2017 123. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    var selectedCategoryName = ""
    
    let categories = ["No Category",
                      "Apple Store",
                      "Bar",
                      "Bookstore",
                      "Club",
                      "Grocery Store",
                      "Historic Building",
                      "House",
                      "Icecream Vendor",
                      "Landmark",
                      "Park"]
    
    var selectedIndexPath = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()

        // When the screen opens it shows a checkmark next to the currently selected category.
        // This comes from the selectedCategoryName property,
        // which is filled in when you segue to this screen
        
        for i in 0..<categories.count { //  alternative - for (i, category) in categories.enumerated()
            if categories[i] == selectedCategoryName {
                // we stored index path 
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
       
        tweakTableview()
    }
    
    func tweakTableview() {
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            // When the user taps a row, you want to remove the checkmark
            // from the previously selected cell and put it in the new cell
            
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.black
        
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.white
            textLabel.highlightedTextColor = textLabel.textColor
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            
            // удобно связать segue c cell тк сразу нашли cell
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        } }
}



























