//
//  SHWFavoritesScheduleViewController.swift
//  Shows
//
//  Created by Will Chilcutt on 9/20/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit
import AlamofireImage

let kSHWFavoritesScheduleViewControllerTitle = "Schedule"

private let kSHWFavoritesScheduleViewControllerCellIdentifier = "kSHWFavoritesScheduleViewControllerCellIdentifier"

class SHWFavoritesScheduleViewController : UIViewController
{
    private var daysArray : [SHWScheduleDay] = []
    
    //MARK: - IBOutlet

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = kSHWFavoritesScheduleViewControllerTitle
        
        self.loadSchedule()
        
        let todayButton = UIBarButtonItem(title: "Today",
                                          style: .plain,
                                          target: self,
                                          action: #selector(self.scrollToTodayAnimated))
        self.navigationItem.leftBarButtonItem = todayButton
    }
    
    @objc private func scrollToTodayAnimated()
    {
        self.scrollToToday(animated: true)
    }
    
    private func scrollToToday(animated : Bool)
    {
        let day = SHWScheduleDay(date: Date().startOfDay, episodes: [])
        guard let todaysDateIndex = self.daysArray.index(of: day) else { return }
        
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: todaysDateIndex), at: .top, animated: animated)
    }
    
    private func loadSchedule()
    {
        let request = SHWGetShowsScheduleRequest(withShows: SHWDataManager.getFavoritedShows())
        
        request.performRequest
        { (response) in
            switch response
            {
                case .failure(_):
                    break
                case .success(let result):
                    
                    self.daysArray.removeAll()
                    self.daysArray.append(contentsOf: result.groupByDate())
                    
                    DispatchQueue.main.async
                    {
                        self.tableView.reloadData()
                        
                        self.scrollToToday(animated: false)
                    }
                    break
            }
        }
    }
}

//MARK: - UITableViewDataSource

extension SHWFavoritesScheduleViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.daysArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let episodeCountForDay = self.daysArray[section].episodes.count
        
        if episodeCountForDay == 0
        {
            return 1
        }
        else
        {
            return episodeCountForDay
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: kSHWFavoritesScheduleViewControllerCellIdentifier)
        
        if cell == nil
        {
            cell = UITableViewCell(style: .subtitle,
                                   reuseIdentifier: kSHWFavoritesScheduleViewControllerCellIdentifier)
        }
        
        if  self.daysArray[indexPath.section].episodes.count == 0
        {
            cell?.textLabel?.text = "No shows today"
            cell?.detailTextLabel?.text = ""
            cell?.imageView?.image = nil
            cell?.backgroundView?.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
        else
        {
            let episode = self.daysArray[indexPath.section].episodes[indexPath.row]
            
            cell?.textLabel?.text       = episode.name
            
            if let date = episode.originalDate
            {
                cell?.detailTextLabel?.text = DateFormatter.justTime.string(from: date)
            }
            
            if  let image = episode.show?.image,
                let url = URL(string: image.medium)
            {
                cell?.imageView?.af_setImage(withURL: url,
                                             completion:
                { (response) in
                    
                    DispatchQueue.main.async
                    {
                        if response.response != nil
                        {
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                    }
                })
            }
            else
            {
                cell?.imageView?.image = nil
            }

            cell?.backgroundView?.backgroundColor = .white
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let formattedString = DateFormatter.prettyPrint.string(from: self.daysArray[section].date)
        
        return formattedString
    }
}

//MARK: - UITableViewDelegate

extension SHWFavoritesScheduleViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
