//
//  SampleSongsAPI.swift
//  JetwayTests
//
//  Created by Cal Stephens on 3/10/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Jetway
import Foundation


// MARK: Song

struct SongResponse: Codable {
    let results: [Song]
}

struct Song: Codable {
    let trackName: String
    let artistName: String
}


// MARK: - SampleSongsAPI

enum SampleSongsAPI {
    
    static func configure() {
        BaseURL.default = URL(string: "https://itunes.apple.com")!
    }
    
    static func songs(for query: String) -> PublicEndpoint<Void, SongResponse> {
        let encodedTerm = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return .endpoint(.GET, "search?term=\(encodedTerm)&entity=song")
    }
    
}
