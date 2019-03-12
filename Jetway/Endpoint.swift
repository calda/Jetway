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
    public let method: HTTP.Method
    public let path: String
    public let additionalRequestConfiguring: ((inout URLRequest) -> Void)?
    
    /// Initializes a new Endpoint.
    ///
    /// - Parameters:
    ///   - method: The HTTP Method to be used as a part of the URLRequest.
    ///   - path: The path of the endpoint on the server.
    ///   - additionalRequestConfiguring: Additional configuration that can be
    ///                                   performed on the `URLRequest` before it is executed.
    ///
    /// - Note: If `path` begins with `http`, then it is assumed to be a fully quantified URL.
    ///         Otherwise, it is appended to `BaseURL.default`.
    ///
    public init(method: HTTP.Method, path: String, additionalRequestConfiguring: ((inout URLRequest) -> Void)?) {
        self.method = method
        self.path = path
        self.additionalRequestConfiguring = additionalRequestConfiguring
    }
    
    /// Initializes a new Endpoint.
    ///
    /// - Parameters:
    ///   - method: The HTTP Method to be used as a part of the URLRequest.
    ///   - path: The path of the endpoint on the server.
    ///   - additionalRequestConfiguring: Additional configuration that can be
    ///                                   performed on the `URLRequest` before it is executed.
    ///
    /// - Note: If `path` begins with `http`, then it is assumed to be a fully quantified URL.
    ///         Otherwise, it is appended to `BaseURL.default`.
    public static func endpoint(
        _ method: HTTP.Method,
        _ path: String,
        additionalRequestConfiguring: ((inout URLRequest) -> Void)? = nil) -> Endpoint
    {
        return Endpoint(method: method, path: path, additionalRequestConfiguring: additionalRequestConfiguring)
    }
    
    // TODO: When I restructure this to have an `API` object passed down into the `Endpoint`,
    // get rid of this awful `http prefix` hack. Always use the base URL from the `API`.
    //
    /// Constructs a URL from the Endpoint's path value.
    ///  - If the path value starts with `http`, it's assumed to be a fully qualified URL.
    ///    Otherwise, it is appended to `BaseURL.default`.
    public func url() throws -> URL {
        // if the path starts with `http`, we assume that it's a fully qualified URL
        if path.hasPrefix("http") {
            guard let url = URL(string: path) else {
                throw EncodingError.invalidValue(path, EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Could not construct a valid URL from the path provided."))
            }
            
            return url
        }
        
        // otherwise, append the path to the default base url
        guard let baseUrl = BaseURL.default else {
            throw BaseURL.Error.notProvided
        }
        
        guard let endpointUrl = URL(string: path, relativeTo: baseUrl) else {
            throw EncodingError.invalidValue(
                baseUrl.absoluteString + "/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/")),
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Could not construct a valid URL from the path provided."))
        }
        
        return endpointUrl
    }
    
}
