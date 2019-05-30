//
//  Response.swift
//  OVOIOSCodingChallenge
//
//  Created by Klemen Košir on 29/05/2019.
//  Copyright © 2019 Our Very Own Pty Ltd. All rights reserved.
//

import Foundation


/// JobsResponse object helps with conversion from json to jobs by also including nextPage number for pagination
class JobsResponse: Decodable {
    private(set) var jobs: [Job]
    private(set) var nextPage: Int?
    
    private enum CodingKeys: String, CodingKey {
        case jobs, nextPage
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jobs = try container.decode([Job].self, forKey: .jobs)
        nextPage = try? container.decodeIfPresent(Int.self, forKey: .nextPage)
    }
}

extension JobsResponse {
    /// Helper append function for pagination
    func append(nextPage response: JobsResponse) {
        jobs.append(contentsOf: response.jobs)
        nextPage = response.nextPage
    }
    
}
