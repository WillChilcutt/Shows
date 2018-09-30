
//  SHWEpisodesViewController.swift
//  Shows
//
//  Created by Will Chilcutt on 9/19/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

private let kSHWEpisodesViewControllerDoneBarButtonItemTitle                        = "Done"
private let kSHWEpisodesViewControllerMarkEpisodesAsWatchedBarButtonItemTitle       = "Mark Episodes as Watched"
private let kSHWEpisodesViewControllerMarkAllEpisodesAsWatchedBarButtonItemTitle    = "Watched All Episodes"


class SHWEpisodesViewController : UIViewController
{
    private let show                            : SHWShow
    private var episodes                        : [SHWEpisode] = []
    private var inMarkAsWatchedMode             : Bool = false
    private var markAllAsWatchedBarButtonItem   : UIBarButtonItem?
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView                            : UITableView!
    @IBOutlet weak var bottomToolBar                        : UIToolbar!
    @IBOutlet weak var markEpisodesAsWatchedBarButtonItem   : UIBarButtonItem!
    
    init(withShow show : SHWShow)
    {
        self.show = show
        
        super.init(nibName: String(describing: SHWEpisodesViewController.self),
                                   bundle: nil)
        
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = self.show.name
        
        if (try? SHWDataManager().isShowFavorited(self.show)) == true
        {
            self.setUnfavoriteButton()
        }
        else
        {
            self.setFavoriteButton()
        }
        
        self.getEpisodes()
    }
    
    private func setFavoriteButton()
    {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Favorite"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.favoriteShow))
    }
    
    private func setUnfavoriteButton()
    {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Favorited"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.unfavoriteShow))
    }
    
    private func getEpisodes()
    {
        SHWDataManager().getEpisodes(forShow: self.show,
                                     freshDataOnly: true)
        {  (response) in
            switch response
            {
                case .failure(let error):
                    print("Error getting episodes: \(error)")
                    break
                case .success(let episodes):
                    
                    self.episodes.removeAll()
                    self.episodes.append(contentsOf: episodes)
                    
                    DispatchQueue.main.async
                    {
                        self.tableView.reloadData()
                    }
            }
        }
    }
    
    @objc private func favoriteShow()
    {
        do
        {
            try SHWDataManager().favoriteShow(self.show)

            self.setUnfavoriteButton()
        }
        catch
        {
            print("Failed to favorite show: \(error)");
        }
    }
    
    @objc private func unfavoriteShow()
    {
        do
        {
            try SHWDataManager().unfavoriteShow(self.show)
            
            self.setFavoriteButton()
        }
        catch
        {
            print("Failed to unfavorite show: \(error)");
        }
    }
    
    @objc private func handleUserWantsToMarkAllAsWatched()
    {
        do
        {
            let dataManager = SHWDataManager()
            
            self.episodes.forEach { $0.watched = true }
            
            try dataManager.updateEpisodes(self.episodes, forShow: self.show)
            
            self.tableView.reloadData()
        }
        catch
        {
            print("Error handleUserWantsToMarkAllAsWatched = \(error)")
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func handleMarkEpisodesAsWatchedButtonPressed(_ sender: Any)
    {
        guard let buttonTitle = self.markEpisodesAsWatchedBarButtonItem.title else { return }
        
        if buttonTitle == kSHWEpisodesViewControllerMarkEpisodesAsWatchedBarButtonItemTitle
        {
            self.markEpisodesAsWatchedBarButtonItem.title = kSHWEpisodesViewControllerDoneBarButtonItemTitle
            
            self.inMarkAsWatchedMode = true
            
            self.markAllAsWatchedBarButtonItem = UIBarButtonItem(title: kSHWEpisodesViewControllerMarkAllEpisodesAsWatchedBarButtonItemTitle,
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(self.handleUserWantsToMarkAllAsWatched))
            
            let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let items : [UIBarButtonItem] = [self.markEpisodesAsWatchedBarButtonItem, flexibleSpaceBarButtonItem, self.markAllAsWatchedBarButtonItem!]
            self.bottomToolBar.setItems(items, animated: true)
        }
        else
        {
            self.markEpisodesAsWatchedBarButtonItem.title = kSHWEpisodesViewControllerMarkEpisodesAsWatchedBarButtonItemTitle
            
            self.inMarkAsWatchedMode = false
            
            self.bottomToolBar.setItems([self.markEpisodesAsWatchedBarButtonItem], animated: true)
        }
    }
}

//MARK: - UITableViewDataSource

extension SHWEpisodesViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.episodes.episodeCatelog().keys.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let episodes = self.episodes.episodeCatelog()[section+1] else { return 0 } //+1 because seasons start at 1
        
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "")
    
        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle,
                                   reuseIdentifier: "")
        }
        
        if let episodes = self.episodes.episodeCatelog()[indexPath.section+1] //+1 because seasons start at 1
        {
            let episode = episodes[indexPath.row]
            
            cell?.textLabel?.text = episode.name
            
            if let date = episode.originalDate
            {
                cell?.detailTextLabel?.text = DateFormatter.prettyPrint.string(from: date)
            }
            
            if episode.watched == true
            {
                cell?.accessoryType = .checkmark
            }
            else
            {
                cell?.accessoryType = .none
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Season \(section+1)" //+1 because seasons start at 1
    }
}

//MARK: - UITableViewDelegate

extension SHWEpisodesViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if  self.inMarkAsWatchedMode == true,
            let episodes = self.episodes.episodeCatelog()[indexPath.section+1] //+1 because seasons start at 1
        {
            let episode = episodes[indexPath.row]
            
            let watchedStatus : Bool
            
            if episode.watched == nil
            {
                watchedStatus = true
            }
            else
            {
                watchedStatus = !episode.watched! //Opposite of what the watch status current is, unwrapped because the previous if statement determined watch -isn't- nil
            }
            
            episode.watched = watchedStatus
            
            do
            {
                let dataManager = SHWDataManager()
                
                try dataManager.updateEpisode(episode, forShow: self.show)
                
                self.episodes = try SHWDataManager().getCachedEpisodes(forShow: self.show)
                            
                self.tableView.reloadRows(at: [indexPath],
                                          with: .automatic)
            }
            catch
            {
                print("Failed to mark episode \(episode) as read/unread: \(error)")
            }
        }
    }
}
