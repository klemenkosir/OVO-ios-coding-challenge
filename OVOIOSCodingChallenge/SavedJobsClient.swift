//  Copyright © 2017 Our Very Own Pty Ltd. All rights reserved.
//

import Foundation

//Returns a the mock data stored in SavedJobsResponse.json
class SavedJobsClient {
    func getSavedJobs(page:Int, completionHandler: @escaping ([String:Any]?, Error?) -> Void) {

        guard let file = Bundle.main.url(forResource: "SavedJobsResponsePage" + String(page) , withExtension: "json"),
            let data = try? Data(contentsOf: file),
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let savedJobs = json as? [String: Any]
            else { completionHandler(nil, NSError(domain: "codingChallengeError", code: 123, userInfo: [:])); return }
        
        return completionHandler(savedJobs, nil)
    }
    
}
