//
//  SHWEpisodesViewController.swift
//  Shows
//
//  Created by Will Chilcutt on 9/19/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

class SHWEpisodesViewController : UIViewController
{
    private let show : SHWShow
    private var episodes : [SHWEpisode] = []

    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    init(withShow show : SHWShow)
    {
        self.show = show
        super.init(nibName: String(describing: SHWEpisodesViewController.self),
                                   bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = self.show.name
        
        self.getEpisodes()
    }
    
    private func getEpisodes()
    {
        LLNetworkManager.sharedInstance.performRequest(SHWNetworkRequest.getEpisodes(forShow: self.show),
                                                       withResultType: [SHWEpisode].self)
        { (response) in
            switch response
            {
                case .failure(let error):
                    print("Error getting episodes: \(error)")
                    break
                case .success(let episodes):
                    self.episodes.removeAll()
                    self.episodes.append(contentsOf: episodes)
                    self.tableView.reloadData()
            }
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
            
            cell?.textLabel?.text       = episode.name
            cell?.detailTextLabel?.text = episode.airstamp
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
    }
}
