//
//  Endpoint+Call.swift
//  Jetway
//
//  Created by Cal Stephens on 3/10/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation


// MARK: - EndpointProtocol Public `call` methods

extension Endpoint where
    RequestType == Void,
    ResponseType == Void
{
    public func call() -> Promise<Void> {
        return EndpointNetworking.call(self,
            requestValueConfiguring: { _ in },
            responseValueHandler: { _ in })
    }
}

extension Endpoint where
    RequestType: Encodable,
    ResponseType == Void
{
    public func call(with requestValue: RequestType) -> Promise<Void> {
        return EndpointNetworking.call(self,
            requestValueConfiguring: { try self.configure(&$0, with: requestValue) },
            responseValueHandler: { _ in })
    }
}

extension Endpoint where
    RequestType == Void,
    ResponseType: Decodable
{
    public func call() -> Promise<ResponseType> {
        return EndpointNetworking.call(self,
            requestValueConfiguring: { _ in },
            responseValueHandler: self.decodeResponsePayload)
    }
}

extension Endpoint where
    RequestType: Encodable,
    ResponseType: Decodable
{
    public func call(with requestValue: RequestType) -> Promise<ResponseType> {
        return EndpointNetworking.call(self,
            requestValueConfiguring: { try self.configure(&$0, with: requestValue) },
            responseValueHandler: self.decodeResponsePayload)
    }
}


// MARK: - EndpointNetworking implementation

fileprivate enum EndpointNetworking {
    
    static func call<RequestType, ResponseType, CredentialsProviderType: CredentialsProvider>(
        _ endpoint: Endpoint<RequestType, ResponseType, CredentialsProviderType>,
        requestValueConfiguring: (inout URLRequest) throws -> Void,
        responseValueHandler: @escaping (Data) throws -> ResponseType) -> Promise<ResponseType>
    {
        let endpointUrlString = (try? endpoint.url())?.absoluteString ?? "Malformed URL"
        let promise = Promise<ResponseType>(purpose: "\(endpoint.method.rawValue) \(endpointUrlString)")
        
        var request: URLRequest

        // allow the endpoint to configure the request
        // (e.g. provide a request body or authorization credentials)
        do {
            request = URLRequest(url: try endpoint.url(), timeoutInterval: 10)
            try requestValueConfiguring(&request)
            try CredentialsProviderType.credentials().configure(&request)
        } catch (let error) {
            promise.reject(error)
            return promise
        }
        
        // kick off the configured request
        URLSession.shared.dataTask(with: request) {  data, response, error in
            guard let response = response as? HTTPURLResponse else {
                promise.reject(ServerError.cannotConnect)
                return
            }
            
            guard response.statusCode == 200 /* ok */ else {
                promise.reject(ServerError.from(statusCode: response.statusCode, body: data, path: endpointUrlString))
                return
            }
            
            if let error = error {
                promise.reject(error)
                return
            }
            
            guard let data = data else {
                promise.reject(DecodingError.valueNotFound(
                    RequestType.self,
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "The response payload didn't include any data.")))
                return
            }
            
            // let the endpoint configure the exact value to be vended back out to the promise
            do {
                promise.fulfill(try responseValueHandler(data))
            } catch (let error) {
                promise.reject(error)
            }
            }.resume()
        
        return promise
    }
    
}


// MARK: - ServerError

public enum ServerError: LocalizedError {
    
    case cannotConnect
    case notFound(resource: String)
    case unauthorized
    case notAcceptable(reason: String)
    case conflict(reason: String)
    case noContent(reason: String)
    case unknown(statusCode: Int, reason: String)
    
    public var errorDescription: String? {
        switch self {
        case .cannotConnect:
            return "We can't connect to the server. Are you connected to the internet?"
        case .notFound:
            return "The requested resource was not found on the server."
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .notAcceptable(let reason):
            return "The web request was not acceptable. (\(reason))"
        case .conflict(let reason):
            return "The request conflicted with existing data on the server. (\(reason))"
        case .noContent(let reason):
            return "There was no content available on the server. (\(reason))"
        case .unknown(let statusCode, let reason):
            return "An unknown error occured. (Code \(statusCode): \(reason))"
        }
    }
    
    static func from(statusCode: Int, body: Data?, path: String) -> ServerError {
        let errorReason: String
        
        if let body = body,
            let bodyDict = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let reason = bodyDict?["reason"] as? String
        {
            errorReason = reason
        }
        else {
            errorReason = "No reason provided."
        }
        
        /// https://www.restapitutorial.com/httpstatuscodes.html
        switch statusCode {
        case 204: return .noContent(reason: errorReason)
        case 401: return .unauthorized
        case 404: return .notFound(resource: path)
        case 406: return .notAcceptable(reason: errorReason)
        case 409: return .conflict(reason: errorReason)
        default: return .unknown(statusCode: statusCode, reason: errorReason)
        }
    }
    
}

