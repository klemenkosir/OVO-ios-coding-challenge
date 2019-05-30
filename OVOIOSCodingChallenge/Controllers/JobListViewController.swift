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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var jobResponse: JobsResponse? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPullToRefresh()
        
        tableView.rowHeight = UITableView.automaticDimension

        SavedJobsClient.getSavedJobsResponse(page: 1) { [weak self] (response, error) in
            guard let safeSelf = self, let r = response else {
                print(error)
                return
            }
            
            safeSelf.jobResponse = r
        }
    }
    
    private func setPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData(_ sender: UIRefreshControl) {
        print("REFRESH DATA")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            sender.endRefreshing()
        }
    }

}

extension JobListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobResponse?.jobs.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobCell
        let job = jobResponse!.jobs[indexPath.row]
        cell.set(job: job)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
}
