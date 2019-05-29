//
//  Job.swift
//  OVOIOSCodingChallenge
//
//  Created by Klemen Košir on 29/05/2019.
//  Copyright © 2019 Our Very Own Pty Ltd. All rights reserved.
//

import Foundation

enum JobStatus: String, Decodable {
    case expired = "Expired"
    case active = "Active"
}

struct Job: Decodable {
    
    let jobId: Int
    let title: String
    let advertiser: String
    let location: String
    let status: JobStatus
    let salary: String
    let isExternal: Bool
    let listedDateUtc: Date
    let savedDateUtc: Date
    
}
