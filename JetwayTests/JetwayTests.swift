//
//  JetwayTests.swift
//  JetwayTests
//
//  Created by Cal Stephens on 3/10/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import XCTest
import Jetway

/// TODO: Add a set of tests that don't depend on making actual URLSession requests
class JetwayTests: XCTestCase {
    
    func testSampleSongsAPIResponse() {
        SampleSongsAPI.configure()
        let expectation = XCTestExpectation(description: "Wait for Sample Songs API Request")
        
        SampleSongsAPI.songs(for: "Earth, Wind, & Fire").call().then { response in
            XCTAssert(!response.results.isEmpty)
            expectation.fulfill()
        }.catch { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }

}
