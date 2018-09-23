//
//  SearchViewControllerTableViewController.swift
//  Stock
//
//  Created by Julio Rosario on 8/7/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import UIKit


protocol SearchDelegate {
    func selectedCryptocurrency(name: String,symbol: String)
}

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    /*var cryptocurrencies = Cryptocurrency.availableCryptos
    
    var delegate : SearchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.flatBlue()
    }
    
    
    //Mark - Specify what happend when a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.selectedCryptocurrency(name: cryptocurrencies[indexPath.row].name,
                                        symbol: cryptocurrencies[indexPath.row].symbol)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //Mark - Populate table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "crypCells", for: indexPath)
        cell.backgroundColor = UIColor.flatBlue()
        
        let name = cryptocurrencies[indexPath.row].name
        
        //Set the text and image
        cell.textLabel?.text = name
        cell.textLabel?.textColor = UIColor.white
        cell.imageView?.image = UIImage(named: name)
        
        return cell
    }
    
    //Mark - Specify the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptocurrencies.count
    }
    
    
    //Mark: Search methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            cryptocurrencies = Cryptocurrency.availableCryptos
        }
        else {
            var temp = [Cryptocurrency]()
            for value in Cryptocurrency.availableCryptos {
                
                //Convert to lower case
               let  str1  = value.name.lowercased()
               let  str2  = searchText.lowercased()
                
                if str1.matches(str2) {
                    temp.append(Cryptocurrency(name: value.name,symbol: value.symbol))
                }
            }
            cryptocurrencies = temp
        }
        tableView.reloadData()
    }*/
}

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
