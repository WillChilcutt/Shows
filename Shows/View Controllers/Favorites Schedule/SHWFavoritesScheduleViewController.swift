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

private let kSHWFavoritesScheduleViewControllerNoShowsTodayCellIdentifier = "kSHWFavoritesScheduleViewControllerNoShowsTodayCellIdentifier"

private let kSHWFavoritesScheduleViewControllerTodayBarButtonTitle = "Today"

class SHWFavoritesScheduleViewController : UIViewController
{
    private var firstLoad           : Bool = true
    private var allDaysArray        : [SHWScheduleDay] = []
    private var filteredDaysArray   : [SHWScheduleDay] = []
    
    //MARK: - IBOutlet

    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = kSHWFavoritesScheduleViewControllerTitle
        
        
        self.tableView.register(UINib(nibName: kSHWShowEpisodeTableViewCellClassName, bundle: nil),
                                forCellReuseIdentifier: kSHWShowEpisodeTableViewCellClassName)
        self.tableView.register(UITableViewCell.self,
                                forCellReuseIdentifier: kSHWFavoritesScheduleViewControllerNoShowsTodayCellIdentifier)
        
        let todayButton = UIBarButtonItem(title: kSHWFavoritesScheduleViewControllerTodayBarButtonTitle,
                                          style: .plain,
                                          target: self,
                                          action: #selector(self.scrollToTodayAnimated))
        self.navigationItem.leftBarButtonItem = todayButton
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(self.loadFreshSchedule))
        
        self.navigationItem.rightBarButtonItem = refreshButton
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.loadSchedule(scrollToTodayWhenDone: self.firstLoad)
        
        self.firstLoad = false
    }
    
    @objc private func scrollToTodayAnimated()
    {
        self.scrollToToday(animated: true)
    }
    
    private func scrollToToday(animated : Bool)
    {
        let day = SHWScheduleDay(date: Date().startOfDay, episodes: [])
        guard let todaysDateIndex = self.filteredDaysArray.index(of: day) else { return }
        
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: todaysDateIndex),
                                   at: .top,
                                   animated: animated)
    }
    
    @objc private func loadFreshSchedule()
    {
        self.loadSchedule(fresh: true,
                          scrollToTodayWhenDone: true)
    }
    
    private func loadSchedule(fresh : Bool? = false, scrollToTodayWhenDone : Bool? = false)
    {
        let dataManager = SHWDataManager()
        guard let favoriteShows = try? dataManager.getFavoritedShows() else { print("Failed to get favorite shows for loadSchedule"); return }
        SHWDataManager().getEpisodes(forShows: favoriteShows,
                                     freshDataOnly: fresh)
        { (response) in
            switch response
            {
                case .failure(_):
                    break
                case .success(let result):

                    self.allDaysArray.removeAll()
                    self.allDaysArray.append(contentsOf: result.groupByDate())
                    
                    self.filteredDaysArray = self.allDaysArray.filteredBy(filterType: .watched)
                    
                    DispatchQueue.main.async
                    {
                        self.tableView.reloadData()

                        if scrollToTodayWhenDone == true
                        {
                            self.scrollToToday(animated: false)
                        }
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
        return self.filteredDaysArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let episodeCountForDay = self.filteredDaysArray[section].episodes.count
        
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
        let noShowsToday = self.filteredDaysArray[indexPath.section].episodes.count == 0
        
        let cellIdentifer : String
        
        if noShowsToday == true
        {
            cellIdentifer = kSHWFavoritesScheduleViewControllerNoShowsTodayCellIdentifier
        }
        else
        {
            cellIdentifer = kSHWShowEpisodeTableViewCellClassName
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer,
                                                 for: indexPath)
        
        if noShowsToday == true
        {
            cell.textLabel?.text                   = "No shows today"
            cell.backgroundView?.backgroundColor   = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
        else if let cell = cell as? SHWShowEpisodeTableViewCell
        {
            let episode = self.filteredDaysArray[indexPath.section].episodes[indexPath.row]
            
            cell.setUp(withEpisode: episode,
                       andTableRefresher: self)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let formattedString = DateFormatter.prettyPrint.string(from: self.filteredDaysArray[section].date)
        
        return formattedString
    }
}

//MARK: - UITableViewDelegate

extension SHWFavoritesScheduleViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let episodesArray =  self.filteredDaysArray[indexPath.section].episodes
        
        guard episodesArray.count > 0, let show = episodesArray[indexPath.row].show else { return }
        
        let vc = SHWEpisodesViewController(withShow: show)
        
        self.navigationController?.pushViewController(vc,
                                                      animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let noShowsToday = self.filteredDaysArray[indexPath.section].episodes.count == 0

        if noShowsToday == true
        {
            return 44
        }
        else
        {
            return 100
        }
    }
}

//MARK: - SHWTableRefresher

extension SHWFavoritesScheduleViewController : SHWTableRefresher
{
    func handleTableNeedsRefreshing()
    {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
}
