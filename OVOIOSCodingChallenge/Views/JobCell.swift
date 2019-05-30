//
//  JobCell.swift
//  OVOIOSCodingChallenge
//
//  Created by Klemen Košir on 29/05/2019.
//  Copyright © 2019 Our Very Own Pty Ltd. All rights reserved.
//

import UIKit

class JobCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var postedDateLabel: UILabel!
    @IBOutlet private weak var savedDateLabel: UILabel!
    @IBOutlet private weak var expiredTag: UIImageView!
    
    
    /// Function that sets the job object to the cell
    ///
    /// - Parameter job: Any Job object as input
    func set(job: Job) {
        let attributedTitleString = NSMutableAttributedString(string: job.title,
                                                              attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .semibold),
                                                                           NSAttributedString.Key.foregroundColor: UIColor(red: 61/255.0, green: 123/255.0, blue: 207/255.0, alpha: 1.0)])
        switch job.status {
        case .active:
            expiredTag.isHidden = true
        case .expired:
            expiredTag.isHidden = false
            let expiredAttrString = NSAttributedString(string: "EXPIRED - ",
                                                       attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .semibold),
                                                                    NSAttributedString.Key.foregroundColor: UIColor(red: 39/255.0, green: 39/255.0, blue: 39/255.0, alpha: 1.0)])
            attributedTitleString.insert(expiredAttrString, at: 0)
        }
        titleLabel.attributedText = attributedTitleString
        
        
        companyNameLabel.text = job.advertiser
        locationLabel.text = job.location
        
        postedDateLabel.text = "Job posted \(job.listedDate?.toString(format: "dd MMM yyyy") ?? "unknwon")"
        savedDateLabel.text = "Saved \(job.savedDate?.toString(format: "dd MMM yyyy") ?? "unkown")"
        
    }

}
