//
//  HTTPMethod.swift
//  Jetway
//
//  Created by Cal Stephens on 3/10/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

/// The action to be performed on a specific resource or at a specific endpoint.
/// - Note: Method descriptions from https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
public enum HTTPMethod: String {
    
    /// The GET method requests a representation of the specified resource.
    /// Requests using GET should only retrieve data.
    case GET
    
    /// The POST method is used to submit an entity to the specified resource,
    /// often causing a change in state or side effects on the server.
    case POST
    
    /// The PUT method replaces all current representations of the target resource with the request payload.
    case PUT
    
    /// The DELETE method deletes the specified resource.
    case DELETE
    
    /// The PATCH method is used to apply partial modifications to a resource.
    case PATCH
    
    /// The HEAD method asks for a response identical to that of a GET request, but without the response body.
    case HEAD
    
    /// The CONNECT method establishes a tunnel to the server identified by the target resource.
    case CONNECT
    
    /// The OPTIONS method is used to describe the communication options for the target resource.
    case OPTIONS
    
    /// The TRACE method performs a message loop-back test along the path to the target resource.
    case TRACE
}
