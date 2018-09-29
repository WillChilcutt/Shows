//
//  SHWFavoritesViewController.swift
//  Shows
//
//  Created by Will Chilcutt on 9/19/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

private let kSHWFavoritesViewControllerCellIdentifier = "kSHWFavoritesViewControllerCellIdentifier"

let kSHWFavoritesViewControllerTitle = "Favorites"

class SHWFavoritesViewController: UIViewController
{
    private var favoriteShowsArray : [SHWShow] = []
    
    @IBOutlet weak var tableView    : UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = kSHWFavoritesViewControllerTitle
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(self.handleUserPressedAddButton))
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.loadFavorites()
    }
    
    private func loadFavorites()
    {
        guard let favoriteShows = try? SHWDataManager().getFavoritedShows() else { print("Failed to get favorite shows for loadFavorites"); return }

        self.favoriteShowsArray = favoriteShows.sorted { return $0.name.lowercased() < $1.name.lowercased() }
        self.tableView.reloadData()
    }
    
    @objc private func handleUserPressedAddButton()
    {
        let searchVC = SHWSearchShowsViewController()
        let navController = UINavigationController(rootViewController: searchVC)
        navController.navigationBar.isTranslucent = false
        
        self.present(navController,
                     animated: true,
                     completion: nil)
    }
}

//MARK: - UITableViewDataSource

extension SHWFavoritesViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return favoriteShowsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: kSHWFavoritesViewControllerCellIdentifier)
        
        if cell == nil
        {
            cell = UITableViewCell(style:.default,
                                   reuseIdentifier: kSHWFavoritesViewControllerCellIdentifier)
        }
        
        let show = self.favoriteShowsArray[indexPath.row]
            
        cell?.textLabel?.text       = show.name
        cell?.detailTextLabel?.text = show.summary
        
        if let image = show.image,
            let url = URL(string: image.medium)
        {
            cell?.imageView?.af_setImage(withURL: url, completion: { (response) in
                
                if response.response != nil
                {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            })
        }
        else
        {
            cell?.imageView?.image = nil
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0
    }
}

//MARK: - UITableViewDelegate

extension SHWFavoritesViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        
        let show = self.favoriteShowsArray[indexPath.row]
        
        let scheduleVC = SHWEpisodesViewController(withShow: show)
        
        self.navigationController?.pushViewController(scheduleVC,
                                                      animated: true)
    }
}
