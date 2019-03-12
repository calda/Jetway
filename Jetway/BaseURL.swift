//
//  BaseURL.swift
//  Jetway
//
//  Created by Cal Stephens on 3/10/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation


// TODO: Wrap this into some `API` descriptor object that can include stuff like the Base URL. Perhaps:
//
// protocol API {
//     var baseUrl: URL
//     var credentialsStore: RequestCredentialsStore
//
//     func endpoint(...) // passes `self` into the Endpoint
//
// }
//
// This sounds a lot better than having a bunch of wacky unrelated globals.
//

public enum BaseURL {
    
    /// The default base URL to be used if otherwise unspecified by an Endpoint
    public static var `default`: URL?
    
    enum Error: LocalizedError {
        case notProvided
        
        var localizedDescription: String {
            switch self {
            case .notProvided:
                return "`BaseURL.default` has not been provided"
            }
        }
    }
    
}
