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


// MARK: - DataEncoder

public struct DataEncoder {
    
    public func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let encoder = EncoderImplementation()
        try value.encode(to: encoder)
        return encoder.data ?? Data()
    }
    
    /// This is almost entirely just a hack
    class EncoderImplementation: Encoder {
        
        var data: Data? = nil
        let codingPath: [CodingKey] = []
        let userInfo: [CodingUserInfoKey : Any] = [:]
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            fatalError("Unsupported")
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            fatalError("Unsupported")
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            fatalError("Unsupported")
        }
        
    }
    
}


// MARK: - DataDecoder

public struct DataDecoder {
    
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        return try T(from: DecoderImplementation(data: data))
    }
    
    /// This is almost entirely just a hack
    struct DecoderImplementation: Decoder {
        let data: Data
        let codingPath: [CodingKey] = []
        let userInfo: [CodingUserInfoKey : Any] = [:]
        
        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            fatalError("Unsupported")
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            fatalError("Unsupported")
        }
        
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            fatalError("Unsupported")
        }
        
    }
    
}
