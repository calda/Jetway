//
//  API.swift
//  Jetway
//
//  Created by Cal Stephens on 3/18/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation

/// An API definition that can be used to construct Endpoints.
public struct API: JetwayAPI {
    
    /// The Base URL of all requests in this API.
    ///
    /// For example: an API with a Base URL of `https://api.jetway.io/` and an
    /// endpoint to the path `/endpoint` would resolve to a final URL of
    /// `https://api.jetway.io/endpoint`.
    public let baseUrl: URL
    
    /// Endpoints in this API use this `RequestCredentialsStore` to retrieve any required credentials.
    public let credentialsStore = RequestCredentialsStore()
    
    /// Headers that are included in every request made as a part of this endpoint.
    /// This is a good place to add Client Secrets or API Keys.
    ///
    /// - Note: Endpoints can provide additional HTTP headers via their `additionalRequestConfiguring` closures
    ///
    public let requestHeaders: [String : String]
    
    /// Creates a new API instance with the given `baseUrl` and `requestHeaders`
    public init(baseUrl: URL, requestHeaders: [String: String] = [:]) {
        self.baseUrl = baseUrl
        self.requestHeaders = requestHeaders
    }
    
    /// Creates a new API instance with the given `baseUrl` and `requestHeaders`
    public init(baseUrl: String, requestHeaders: [String: String] = [:]) {
        self.init(baseUrl: URL(string: baseUrl)!, requestHeaders: requestHeaders)
    }
    
}


/// MARK: - APIProtocol

/// You can define your own concrete API instances by conforming to this protocol.
public protocol JetwayAPI {
    
    var baseUrl: URL { get }
    
    var credentialsStore: RequestCredentialsStore { get }
    
    var requestHeaders: [String: String] { get }
    
    
    /// Initializes a new Endpoint within this API.
    ///
    /// - Parameters:
    ///   - method: The HTTP Method to be used as a part of the URLRequest.
    ///   - path: The path of the endpoint on the server.
    ///   - additionalRequestConfiguring: Additional configuration that can be
    ///                                   performed on the `URLRequest` before it is executed.
    func endpoint<RequestType, ResponseType, CredentialsProviderType>(
        _ method: HTTP.Method,
        _ path: String,
        additionalRequestConfiguring: ((inout URLRequest) -> Void)?)
        -> Endpoint<RequestType, ResponseType, CredentialsProviderType>
    
}

public extension API {
    
    func endpoint<RequestType, ResponseType, CredentialsProviderType>(
        _ method: HTTP.Method,
        _ path: String,
        additionalRequestConfiguring: ((inout URLRequest) -> Void)? = nil)
        -> Endpoint<RequestType, ResponseType, CredentialsProviderType>
    {
        return Endpoint(in: self, method: method, path: path, additionalRequestConfiguring: additionalRequestConfiguring)
    }
    
}
