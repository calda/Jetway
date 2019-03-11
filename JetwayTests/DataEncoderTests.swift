//
//  DataEncoderTests.swift
//  JetwayTests
//
//  Created by Cal Stephens on 3/11/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import XCTest
import Jetway


class DataEncoderTests: XCTestCase {
    
    func testDataEncoderAndDecoderRoundtrip() {
        let dataContainer = SomeDataContainer(with: Data("Some Piece of Data".utf8))
        
        let encodedData = (try? DataEncoder().encode(dataContainer)) ?? Data()
        XCTAssertEqual(dataContainer.underlyingData, encodedData)
        
        let decodedObject = try? DataDecoder().decode(SomeDataContainer.self, from: encodedData)
        XCTAssertEqual(dataContainer.underlyingData, decodedObject?.underlyingData)
    }
    
}


struct SomeDataContainer: Codable {
    
    let underlyingData: Data
    
    init(with data: Data) {
        self.underlyingData = data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(underlyingData)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.underlyingData = try container.decode(Data.self)
    }
    
}
