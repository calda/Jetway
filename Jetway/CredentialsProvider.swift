//
//  CredentialsProvider.swift
//  Jetway
//
//  Created by Cal Stephens on 3/10/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation


public protocol CredentialsProvider {
    associatedtype CredentialsType: Credentials
    static func credentials() throws -> CredentialsType
}

public protocol Credentials {
    func configure(_ request: inout URLRequest) throws
}


// MARK: - NoAuthenticationRequired

public struct NoAuthenticationRequired: CredentialsProvider {
    
    public typealias CredentialsType = NoCredentials
    
    public struct NoCredentials: Credentials {
        public func configure(_ request: inout URLRequest) throws {
            return
        }
    }
    
    public static func credentials() throws -> NoAuthenticationRequired.CredentialsType {
        return NoCredentials()
    }
    
}


// MARK: - RequiresCredentials

public struct Requires<CredentialsType: Credentials>: CredentialsProvider {
    
    public static func credentials() throws -> CredentialsType {
        return try RequestCredentialsStore.global.credentials(of: CredentialsType.self)
    }
    
}


// MARK: - RequestCredentialsStore

/// A global store for blocks that provide credentials
public class RequestCredentialsStore {
    
    /// The global Credentials Store.
    /// Credentials registered with this Store are automatically used in requests that require Credentials of that type.
    public static let global = RequestCredentialsStore()
    private init() { }
    
    private typealias CredentialsTypeName = String
    private var credentialsProviders = [CredentialsTypeName: () throws -> (Any)]()
    
    /// Registers a Credentials provider block that is used whenever a request is fired
    /// that requires Credentials of the given type.
    public func registerCredentialsProvider<CredentialsType: Credentials>(
        _ providerBlock: @escaping () throws -> (CredentialsType))
    {
        credentialsProviders[String(describing: CredentialsType.self)] = providerBlock
    }
    
    /// Retrieves Credentials that have previously been registered.
    fileprivate func credentials<CredentialsType: Credentials>(
        of type: CredentialsType.Type) throws -> CredentialsType
    {
        guard let credentialsProvider = credentialsProviders[String(describing: CredentialsType.self)] else {
            throw Error.notCongfigured(forType: String(describing: CredentialsType.self))
        }
        
        let untypedCredentials = try credentialsProvider()
        
        guard let typedCredentials = untypedCredentials as? CredentialsType else {
            throw Error.unacceptableValue(untypedCredentials, forType: String(describing: CredentialsType.self))
        }
        
        return typedCredentials
    }
    
    enum Error: LocalizedError {
        case notCongfigured(forType: String)
        case unacceptableValue(Any, forType: String)
        
        var errorDescription: String? {
            switch self {
            case .notCongfigured(let credentialsType):
                return "No credentials have been provided for the required type (\(credentialsType))"
            case .unacceptableValue(let value, let credentialsType):
                return "The provided credentials (\(value)) were unacceptable for the required type (\(credentialsType))"
            }
        }
    }
    
}
