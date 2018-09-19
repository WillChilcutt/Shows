//
//  SHWSearchShowsViewController.swift
//  Shows
//
//  Created by Will Chilcutt on 9/18/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

private let kSHWSearchShowsViewControllerCellIdentifier = "kSHWSearchShowsViewControllerCellIdentifier"

class SHWSearchShowsViewController : UIViewController
{
    private var showResults : [SHWShowSearchResult]?
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var searchBar    : UISearchBar!
    @IBOutlet weak var tableView    : UITableView!
}

//MARK: - UITableViewDataSource

extension SHWSearchShowsViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let showResults = self.showResults else { return 0 }
        
        return showResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: kSHWSearchShowsViewControllerCellIdentifier)
        
        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle,
                                   reuseIdentifier: kSHWSearchShowsViewControllerCellIdentifier)
        }
        
        if let result = self.showResults?[indexPath.row]
        {
            cell?.textLabel?.text       = result.show.name
            cell?.detailTextLabel?.text = result.show.summary
        }
        
        return cell!
    }
}

//MARK: - UITableViewDelegate

extension SHWSearchShowsViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        
        guard let result = self.showResults?[indexPath.row] else { return }
        
        print("Selected \(result.show.name)")
    }
}

//MARK: - UISearchBarDelegate

extension SHWSearchShowsViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        guard let searchTerm = searchBar.text else { return }
        
        print("User wants to search : \(searchTerm)")
        
        let request = SHWNetworkRequest.searchShows(withQuery: searchTerm)
        
        LLNetworkManager.sharedInstance.performRequest(request,
                                                       withResultType: [SHWShowSearchResult].self)
        { (response) in
            switch response
            {
                case .failure(let error):
                    print("Error getting search results: \(error)")
                    break
                case .success(let result):
                    self.showResults = result
                    
                    DispatchQueue.main.async
                    {
                        self.tableView.reloadData()
                        self.searchBar.resignFirstResponder()
                    }
                    break
            }
        }
    }
}
