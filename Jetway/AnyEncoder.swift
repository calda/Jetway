//
//  AnyEncoder.swift
//  Jetway
//
//  Created by Cal Stephens on 1/24/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation


// MARK: - AnyEncoder

public struct AnyEncoder {
    
    enum EncodingImplementation {
        case json(JSONEncoder)
        case plist(PropertyListEncoder)
        case data(DataEncoder)
    }
    
    private var implementation: EncodingImplementation
    
    public init(_ encoder: JSONEncoder) { self.implementation = .json(encoder) }
    public init(_ encoder: PropertyListEncoder) { self.implementation = .plist(encoder) }
    public init(_ encoder: DataEncoder) { self.implementation = .data(encoder) }
    
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        switch implementation {
        case .json(let encoder):
            return try encoder.encode(value)
        case .plist(let encoder):
            return try encoder.encode(value)
        case .data(let encoder):
            return try encoder.encode(value)
        }
    }
    
}

public protocol EncoderProvider {
    static var preferredEncoder: AnyEncoder { get }
}


// MARK: - AnyDecoder

public struct AnyDecoder {
    
    enum DecodingImplementation {
        case json(JSONDecoder)
        case plist(PropertyListDecoder)
        case data(DataDecoder)
    }
    
    private var implementation: DecodingImplementation
    
    public init(_ decoder: JSONDecoder) { self.implementation = .json(decoder) }
    public init(_ decoder: PropertyListDecoder) { self.implementation = .plist(decoder) }
    public init(_ decoder: DataDecoder) { self.implementation = .data(decoder) }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        switch implementation {
        case .json(let decoder):
            return try decoder.decode(type, from: data)
        case .plist(let decoder):
            return try decoder.decode(type, from: data)
        case .data(let decoder):
            return try decoder.decode(type, from: data)
        }
    }
}

public protocol DecoderProvider {
    static var preferredDecoder: AnyDecoder { get }
}
