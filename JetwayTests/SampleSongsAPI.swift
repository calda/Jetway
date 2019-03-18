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
    
    private static let api = API(baseUrl: "https://itunes.apple.com")
    
    static func songs(for query: String) -> PublicEndpoint<Void, SongResponse> {
        return api.endpoint(.GET, "search?term=\(query.percentEncoded)&entity=song")
    }
    
}
