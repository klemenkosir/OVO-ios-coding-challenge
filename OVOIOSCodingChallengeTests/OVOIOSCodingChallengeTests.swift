//
//  OVOIOSCodingChallengeTests.swift
//  OVOIOSCodingChallengeTests
//
//  Created by Vlado Grancaric on 18/9/17.
//  Copyright © 2017 Vlado Grancaric. All rights reserved.
//

import XCTest
@testable import OVOIOSCodingChallenge

class OVOIOSCodingChallengeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDateParsing() {
        
        let dateString = "2017-05-26T04:25:20.62Z"
        
        let date = Date(from: dateString)
        
        XCTAssertNotNil(date)
        
    }
    
}
