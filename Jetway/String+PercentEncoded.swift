//
//  String+PercentEncoded.swift
//  Jetway
//
//  Created by Cal Stephens on 3/18/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation

public extension String {
    
    /// This String with Percent Encoding appropriate for a URL Query parameter.
    public var percentEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
}
