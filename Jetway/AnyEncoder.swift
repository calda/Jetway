//
//  AnyEncoder.swift
//  Jetway
//
//  Created by Cal Stephens on 1/24/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import Foundation


extension JSONEncoder: AnyEncoder { }
extension JSONDecoder: AnyDecoder { }

extension PropertyListEncoder: AnyEncoder { }
extension PropertyListDecoder: AnyDecoder { }

extension DataEncoder: AnyEncoder { }
extension DataDecoder: AnyDecoder { }


// MARK: - AnyEncoder

public protocol AnyEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

public protocol EncoderProvider {
    static var preferredEncoder: AnyEncoder { get }
}


// MARK: - AnyDecoder

public protocol AnyDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

public protocol DecoderProvider {
    static var preferredDecoder: AnyDecoder { get }
}


// MARK: - DataEncoder

struct DataEncoder {
    
    func encode<T>(_ value: T) throws -> Data where T : Encodable {
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

struct DataDecoder {
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
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
