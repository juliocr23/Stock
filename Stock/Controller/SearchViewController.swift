//
//  SearchViewControllerTableViewController.swift
//  Stock
//
//  Created by Julio Rosario on 8/7/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import UIKit


protocol SearchDelegate {
    func selectedCryptocurrency(cryp: CryptocurrencyBank)
}

class SearchViewController: UITableViewController {
    
    
    var cryptocurrency: CryptocurrencyBank = .Bitcoin
    var delegate : SearchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    //Mark - Specify what happend when a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCryp  =  cryptocurrency.get(number: indexPath.row)
        delegate?.selectedCryptocurrency(cryp: selectedCryp)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark - Populate table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "crypCells", for: indexPath)
        
        //Set the text and image
        cell.textLabel?.text = cryptocurrency.name[indexPath.row]
        cell.imageView?.image = cryptocurrency.image[indexPath.row]
        
        return cell
    }
    
    //Mark - Specify the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptocurrency.name.count
    }

}
