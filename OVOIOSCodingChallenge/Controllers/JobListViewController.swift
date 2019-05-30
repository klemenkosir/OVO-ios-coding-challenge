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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var jobResponse: JobsResponse?
    
    private var isLoadingNextPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPullToRefresh()
        
        tableView.rowHeight = UITableView.automaticDimension

        loadPage()
    }
    
    private func setPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func loadPage(_ page: Int = 1) {
        SavedJobsClient.getSavedJobsResponse(page: page) { [weak self] (response, error) in
            guard let safeSelf = self, let r = response else {
                print(error)
                return
            }
            if let jr = safeSelf.jobResponse {
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
            sender.endRefreshing()
        }
    }

}

extension JobListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobResponse?.jobs.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row+1 == jobResponse!.jobs.count {
            loadNextPage()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobCell
        let job = jobResponse!.jobs[indexPath.row]
        cell.set(job: job)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
}
