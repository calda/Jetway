//
//  Endpoint+Codable.swift
//  Jetway
//
//  Created by Cal Stephens on 3/10/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation


// MARK: - Endpoint + Automatic Encoding

extension Endpoint where
    RequestType: Encodable
{
    private var defaultEncoder: AnyEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return AnyEncoder(encoder)
    }
    
    func configure(_ request: inout URLRequest, with requestValue: RequestType) throws {
        request.method = method
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = (RequestType.self as? EncoderProvider.Type)?.preferredEncoder ?? defaultEncoder
        request.httpBody = try encoder.encode(requestValue)
        
        additionalRequestConfiguring?(&request)
    }
}


// MARK: - Endpoint + Automatic Decoding

extension Endpoint where
    ResponseType: Decodable
{
    
    private var defaultDecoder: AnyDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return AnyDecoder(decoder)
    }
    
    func decodeResponsePayload(_ data: Data) throws -> ResponseType {
        let decoder = (ResponseType.self as? DecoderProvider.Type)?.preferredDecoder ?? defaultDecoder
        
        do {
            return try decoder.decode(ResponseType.self, from: data)
        }
            
        catch DecodingError.dataCorrupted(let context) {
            // manually handle JSON fragments. this only works for Strings at the moment.
            // https://bugs.swift.org/browse/SR-6163
            if let error = context.underlyingError,
                (error as NSError).code == 3840, // "JSON text did not start with array or object and option to allow fragments not set."
                let fragmentString = String(data: data, encoding: .utf8),
                let fragmentArray = "[\"\(fragmentString)\"]".data(using: .utf8),
                let decodedFragment = try decoder.decode([ResponseType].self, from: fragmentArray).first
            {
                return decodedFragment
            }
            
            throw DecodingError.dataCorrupted(context)
        }
    }
}
