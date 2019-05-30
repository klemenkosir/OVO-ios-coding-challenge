//
//  SavedJobsClientExtension.swift
//  OVOIOSCodingChallenge
//
//  Created by Klemen Košir on 29/05/2019.
//  Copyright © 2019 Our Very Own Pty Ltd. All rights reserved.
//

import Foundation


extension SavedJobsClient {
    
    static func getSavedJobsResponse(page: Int, completionHandler: @escaping (_ response: JobsResponse?, _ error: Error?) -> Void) {
        
        guard let file = Bundle.main.url(forResource: "SavedJobsResponsePage\(page)" , withExtension: "json")
            else {
                completionHandler(nil, NSError(domain: "codingChallengeError", code: 123))
                return
        }
        
        do {
            let data = try Data(contentsOf: file)
            // Here we try to decode JSON data object to JobsResponse object that conforms to Decodable
            let response = try JSONDecoder().decode(JobsResponse.self, from: data)
            return completionHandler(response, nil)
        }
        catch let err {
            return completionHandler(nil, err)
        }
    }
    
}
