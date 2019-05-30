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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var jobResponse: JobsResponse?
    
    private var jobs: [Job]? {
        return filteredJobs ?? jobResponse?.jobs
    }
    
    private var filteredJobs: [Job]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var isLoadingNextPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPullToRefresh()
        setupSearch()
        
        tableView.rowHeight = UITableView.automaticDimension

        loadPage()
    }
    
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
    
    private func setPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func loadPage(_ page: Int = 1, reload: Bool = false) {
        SavedJobsClient.getSavedJobsResponse(page: page) { [weak self] (response, error) in
            guard let safeSelf = self, let r = response else {
                print(error)
                return
            }
            if let jr = safeSelf.jobResponse, !reload {
                jr.append(nextPage: r)
            }
            else {
                safeSelf.jobResponse = r
            }
            safeSelf.tableView.reloadData()
            safeSelf.isLoadingNextPage = false
        }
    }
    
    private func loadNextPage() {
        guard !isLoadingNextPage else { return }
        isLoadingNextPage = true
        if let nextPage = jobResponse?.nextPage {
            print("NEXT PAGE: ", nextPage)
            loadPage(nextPage)
        }
        else {
            // seems like this is the last page
            isLoadingNextPage = false
        }
    }
    
    @objc private func refreshData(_ sender: UIRefreshControl) {
        print("REFRESH DATA")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.loadPage(1, reload: true)
            sender.endRefreshing()
        }
    }

}

extension JobListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row+1 == jobs!.count {
            loadNextPage()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobCell
        let job = jobs![indexPath.row]
        cell.set(job: job)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
}

extension JobListViewController: SearchDelegate {
    
    func searchEnded() {
        filteredJobs = nil
    }
    
    func searchViewDidChange(_ searchString: String?) {
        guard let lcSearchString = searchString?.lowercased(), !lcSearchString.isEmpty else {
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
