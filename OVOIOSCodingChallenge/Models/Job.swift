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


/// Class definition for the Job model that conforms to Decodable protocol
class Job: Decodable {
    
    let jobId: Int
    let title: String
    let advertiser: String
    let location: String
    let status: JobStatus
    let salary: String
    let isExternal: Bool
    private let listedDateUtc: String
    private let savedDateUtc: String
    
    lazy var listedDate: Date = {
        return Date(from: self.listedDateUtc) ?? Date()
    }()
    
    lazy var savedDate: Date = {
        return Date(from: self.savedDateUtc) ?? Date()
    }()
    
}
