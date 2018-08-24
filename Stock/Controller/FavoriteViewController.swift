//
//  FavoriteViewController.swift
//  Stock
//
//  Created by Julio Rosario on 8/13/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import UIKit

class FavoriteViewController: UITableViewController, UISearchBarDelegate {

    var favorites = [String]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //Mark - Specify what happend when a row is selected
   /* override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      
    }
    
    //Mark - Populate table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        return
    }
    
    //Mark - Specify the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
    }*/
}
