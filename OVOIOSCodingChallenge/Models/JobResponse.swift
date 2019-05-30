//
//  Response.swift
//  OVOIOSCodingChallenge
//
//  Created by Klemen Košir on 29/05/2019.
//  Copyright © 2019 Our Very Own Pty Ltd. All rights reserved.
//

import Foundation

struct JobsResponse: Decodable {
    let jobs: [Job]
    let nextPage: Int
}
