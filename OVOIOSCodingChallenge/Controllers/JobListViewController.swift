//
//  JobListViewController.swift
//  OVOIOSCodingChallenge
//
//  Created by Klemen Košir on 29/05/2019.
//  Copyright © 2019 Our Very Own Pty Ltd. All rights reserved.
//

import UIKit

class JobListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var navBarContentView: UIView!
    private var refreshControl: UIRefreshControl!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var jobResponse: JobsResponse?
    
    private var jobs: [Job] {
        if let fj = filteredJobs {
            return fj
        }
        if let j = jobResponse?.jobs {
            return j
        }
        return []
    }
    
    /// filtered jobs contains jobs filtered by search string, if nil all jobs will be presented
    private var filteredJobs: [Job]? {
        didSet {
            // everytime we set filtered jobs we need to reload the tableview to show the latest data
            tableView.reloadData()
            
            // refresh is disabled while we are searching
            if let _ = filteredJobs {
                tableView.refreshControl = nil
                canLoadNextPage = false
            }
            else {
                tableView.refreshControl = refreshControl
                canLoadNextPage = true
            }
        }
    }
    
    /// This boolean tells us if laoding of the next page is currently in progress or not
    private var canLoadNextPage = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPullToRefresh()
        setupSearch()
        loadPage()
        
        // Added observers so we can adjust tableView'S contentInset when the keyboard comes up
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// Adds SearchViewController as childVC and sets all the necessary constraints
    private func setupSearch() {
        let searchVC = SearchViewController.viewController()
        searchVC.delegate = self
        searchVC.view.translatesAutoresizingMaskIntoConstraints = false
        searchVC.willMove(toParent: self)
        navBarContentView.addSubview(searchVC.view)
        self.addChild(searchVC)
        searchVC.didMove(toParent: self)
        
        navBarContentView.topAnchor.constraint(equalTo: searchVC.view.topAnchor, constant: 0).isActive = true
        navBarContentView.bottomAnchor.constraint(equalTo: searchVC.view.bottomAnchor, constant: 0).isActive = true
        navBarContentView.trailingAnchor.constraint(equalTo: searchVC.view.trailingAnchor, constant: 0).isActive = true
    }
    
    /// Sets the UIRefreshControl to tableView and adds target to it
    private func setPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    /// Function is used for loading jobs per page, if reload is true it will override all previous data
    private func loadPage(_ page: Int = 1, reload: Bool = false) {
        SavedJobsClient.getSavedJobsResponse(page: page) { [weak self] (response, error) in
            guard let safeSelf = self else { return }
            guard let r = response else {
                safeSelf.showPageLoadErrorAlert()
                return
            }
            if let jr = safeSelf.jobResponse, !reload {
                jr.append(nextPage: r)
            }
            else {
                safeSelf.jobResponse = r
            }
            safeSelf.tableView.reloadData()
            safeSelf.canLoadNextPage = true
        }
    }
    
    /// Called when we want to load the next page
    private func loadNextPage() {
        // checks if already loading the next page, if it is then just skip
        // this is a very basic pagination implementation, without queueing next page requests and prefetching
        guard canLoadNextPage else { return }
        canLoadNextPage = false
        // checks if there is a next page
        if let nextPage = jobResponse?.nextPage {
            loadPage(nextPage)
        }
        else {
            // seems like this is the last page
            canLoadNextPage = true
        }
    }
    
    /// Shows an alert telling user something went wrong and they should try to refresh
    private func showPageLoadErrorAlert() {
        let alertVC = UIAlertController(title: "Ooops!", message: "There seems to be a problem while loading jobs.\nPlease try refreshing.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc private func refreshData(_ sender: UIRefreshControl) {
        // Async added because we are using local data and we want it to feel like a real refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadPage(1, reload: true)
            sender.endRefreshing()
        }
    }

}

// MARK: - Keyboard
extension JobListViewController {
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let newFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var insets: UIEdgeInsets
            if #available(iOS 11.0, *) {
                // on newer devices (X, Xs, etc) there is a bottom safeArea so we remove that because it's automaticaly applied
                insets = UIEdgeInsets( top: 0, left: 0, bottom: newFrame.height - tableView.safeAreaInsets.bottom, right: 0 )
            } else {
                insets = UIEdgeInsets( top: 0, left: 0, bottom: newFrame.height, right: 0 )
            }
            
            /*
             We set the contentInset and scrollIndicatorInsets to keyboard height so the user can scroll through the whole list even
             when the keyboard is visible.
             */
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // ContentInsets back to zero because keyboard will hide
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
    
}

// MARK: - TableView Delegate and DataSource
extension JobListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfCells = jobs.count
        
        // We check if there is next page and add 1 for the last loadingCell, we dont support pagination while filtering
        if (jobResponse?.hasNextPage ?? true) == true && canLoadNextPage {
            numOfCells += 1
        }
        
        // if there is no jobs we show the label saying "No jobs" to the user
        infoLabel.isHidden = (numOfCells != 0)
        
        return numOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= jobs.count {
            // show last cell as loading cell if row higher than number of jobs
            return tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
        }
        else if indexPath.row+1 == jobs.count {
            // before presenting the last cell we check if there is more data(next page), if there is, tableView will get reloaded
            loadNextPage()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobCell
        let job = jobs[indexPath.row]
        cell.set(job: job)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= jobs.count {
            return 100
        }
        return 180
    }
    
}

// MARK: - Search Delegate
extension JobListViewController: SearchDelegate {
    
    func searchEnded() {
        filteredJobs = nil
    }
    
    func searchViewDidChange(_ searchString: String?) {
        guard let lcSearchString = searchString?.lowercased(), !lcSearchString.isEmpty else {
            // if searchString is nil or empty we want to fallback to all jobs so we set filteredJobs to nil
            filteredJobs = nil
            return
        }
        // very basic implementation of search which just checks if title, advertiser or location contain a given string
        filteredJobs = jobResponse?.jobs.filter { job -> Bool in
            return job.title.lowercased().contains(lcSearchString) ||
                job.advertiser.lowercased().contains(lcSearchString) ||
                job.location.lowercased().contains(lcSearchString)
        }
    }
    
}
