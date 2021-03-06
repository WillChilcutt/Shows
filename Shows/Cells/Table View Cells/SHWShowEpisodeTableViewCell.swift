//
//  SHWShowEpisodeTableViewCell.swift
//  Shows
//
//  Created by Will Chilcutt on 9/22/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

let kSHWShowEpisodeTableViewCellClassName = String(describing: SHWShowEpisodeTableViewCell.self)

class SHWShowEpisodeTableViewCell : UITableViewCell
{
    //MARK: - IBOutlet
    @IBOutlet weak var timeLabel                        : UILabel!
    @IBOutlet weak var showImageView                    : UIImageView!
    @IBOutlet weak var showNameLabel                    : UILabel!
    @IBOutlet weak var episodeNameLabel                 : UILabel!
    @IBOutlet weak var watchedEpisodeCoverView          : UIView!
    @IBOutlet weak var seasonNumberEpisodeNumberLabel   : UILabel!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.timeLabel.text         = ""
        self.showNameLabel.text     = ""
        self.showImageView.image    = nil
        self.episodeNameLabel.text  = ""
    }

    func setUp(withEpisode episode : SHWEpisode, andTableRefresher tableRefresh : SHWTableRefresher)
    {
        self.showNameLabel.text                 = episode.show?.name
        self.episodeNameLabel.text              = episode.name
        
        if episode.watched == nil
        {
            self.watchedEpisodeCoverView.isHidden = true
        }
        else
        {
            self.watchedEpisodeCoverView.isHidden   = !episode.watched!
        }
        
        if let date = episode.originalDate
        {
            self.timeLabel.text = DateFormatter.justTime.string(from: date)
        }
        
        if  let image = episode.show?.image,
            let url = URL(string: image.medium)
        {   
            self.showImageView.af_setImage(withURL: url,
                                         completion:
            { (response) in
                
                DispatchQueue.main.async
                {
                    if response.response != nil
                    {
                        tableRefresh.handleTableNeedsRefreshing()
                    }
                }
            })
        }
        else
        {
            self.showImageView.image = nil
        }
        
        let seasonString    = String(format: "%02d", episode.season)
        let episodeString   = String(format: "%02d", episode.number)
        
        self.seasonNumberEpisodeNumberLabel.text = "S" + seasonString + "E" + episodeString
    }
}
