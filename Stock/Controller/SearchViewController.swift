//
//  SearchViewControllerTableViewController.swift
//  Stock
//
//  Created by Julio Rosario on 8/7/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import UIKit


protocol SearchDelegate {
    func selectedCryptocurrency(name: String)
}

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    var cryptocurrencies = CryptocurrencyBank.name
    
    var delegate : SearchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.flatBlue()
    }
    
    
    //Mark - Specify what happend when a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.selectedCryptocurrency(name: cryptocurrencies[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark - Populate table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "crypCells", for: indexPath)
        cell.backgroundColor = UIColor.flatBlue()
        
        let name = cryptocurrencies[indexPath.row]
        
        //Set the text and image
        cell.textLabel?.text = name
        cell.textLabel?.textColor = UIColor.white
        cell.imageView?.image = UIImage(named: name)
        
        //cell.addButton
        
        
        return cell
    }
    
    //Mark - Specify the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptocurrencies.count
    }
    
    
    //Mark: Search methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            cryptocurrencies = CryptocurrencyBank.name
        }
        else {
            var temp = [String]()
            for name in CryptocurrencyBank.name {
                
                //Convert to lower case
               let  str1  = name.lowercased()
               let  str2  = searchText.lowercased()
                
                if str1.matches(str2) {
                    temp.append(name)
                }
            }
            cryptocurrencies = temp
        }
        tableView.reloadData()
    }
}

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
