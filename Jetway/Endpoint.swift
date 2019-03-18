//
//  Endpoint.swift
//  Jetway
//
//  Created by Cal Stephens on 3/10/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation


/// An Endpoint that doesn't require any credentials.
public typealias PublicEndpoint<RequestType, ResponseType> = Endpoint<RequestType, ResponseType, NoAuthenticationRequired>

/// An Endpoint that performs some action without any Request content or Response content
public typealias ActionEndpoint<CredentialsProviderType: CredentialsProvider> = Endpoint<Void, Void, CredentialsProviderType>


/// An statically-typed API endpoint.
///
/// - Generic Parameters:
///   - RequestType: The type of object sent to the server as a part of the URLRequest.
///   - ResponseType: The type of object recieved from the server as part of a URLResponse.
///   - CredentialsProviderType: A `CredentialsProvider` that provides credentials for
///                              authentication with the server if necessary.
///
/// - Note: The Endpoint will only be callable if:
///   - `RequestType` is `Void` or `Encodable`
///   - `ResponseType` is `Void` or `Decodable`
///
public struct Endpoint
   <RequestType,
    ResponseType,
    CredentialsProviderType: CredentialsProvider>
{
    public let api: API
    public let method: HTTP.Method
    public let path: String
    public let additionalRequestConfiguring: ((inout URLRequest) -> Void)?
    
    /// Initializes a new Endpoint.
    ///
    /// - Parameters:
    ///   - api: The API that this Endpoint is a member of.
    ///   - method: The HTTP Method to be used as a part of the URLRequest.
    ///   - path: The path of the endpoint on the server.
    ///   - additionalRequestConfiguring: Additional configuration that can be
    ///                                   performed on the `URLRequest` before it is executed.
    ///
    public init(
        in api: API,
        method: HTTP.Method,
        path: String,
        additionalRequestConfiguring: ((inout URLRequest) -> Void)?)
    {
        self.api = api
        self.method = method
        self.path = path
        self.additionalRequestConfiguring = additionalRequestConfiguring
    }
    
    /// The full URL represented by this Endpoint.
    public func url() throws -> URL {
        let slash = CharacterSet(charactersIn: "/")
        let fullUrlPath = api.baseUrl.absoluteString.trimmingCharacters(in: slash)
            + "/"
            + path.trimmingCharacters(in: slash)
        
        guard let fullUrl = URL(string: fullUrlPath) else {
            throw Error.malformedUrl(fullUrlPath)
        }
        
        return fullUrl
    }
    
    public enum Error: LocalizedError {
        case malformedUrl(String)
        
        var localizedDescription: String {
            switch self {
            case .malformedUrl(let path):
                return "Could not construct a URL from the given base and path pair (\(path))."
            }
        }
    }
    
}
