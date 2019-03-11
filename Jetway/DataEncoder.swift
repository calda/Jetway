//
//  DataEncoder.swift
//  Jetway
//
//  Created by Cal Stephens on 3/11/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//


import Foundation


// This implementation is so gnarly because `unkeyedContainer` and `container(keyedBy:)` can't throw.
// Since those methods have to return an actual container, we have to create an
// `Unsupported(Unkeyed/Keyed)(Encoding/Decoding)Container` that just throws on every operation.
// Those for Unsupported* containers account for like 75%+ of the boilerplate in this file.


// MARK: - DataEncoder

/// An Encoder that serves as a `Data` passthrough.
/// The value encoded to the `singleValueContainer` is converted directly to `Data`.
public struct DataEncoder {
    
    public init() { }
    
    public func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let encoder = EncoderImplementation()
        try value.encode(to: encoder)
        return encoder.data ?? Data()
    }
    
    enum Error: LocalizedError {
        case unsupportedContainerType
        case unsupportedValue
        
        var localizedDescription: String {
            switch self {
            case .unsupportedContainerType:
                return "Unsupported container type. DataEncoder only supports `singleValueContainer`."
            case .unsupportedValue:
                return "Could not covert the given value to `Data`."
            }
        }
    }
    
    class EncoderImplementation: Encoder, SingleValueEncodingContainer {
        
        var data: Data? = nil
        let codingPath: [CodingKey] = []
        let userInfo: [CodingUserInfoKey : Any] = [:]
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            return self
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            return UnsupportedUnkeyedCodingContainer(parent: self)
        }
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            return KeyedEncodingContainer<Key>(UnsupportedKeyedCodingContainer<Key>(parent: self))
        }
        
        func encode<T>(_ value: T) throws where T : Encodable {
            if let data = value as? Data {
                self.data = data
            } else {
                throw Error.unsupportedValue
            }
        }
        
        func encodeNil() throws {
            data = nil
        }
        
        func encode(_ value: Bool) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: String) throws {
            data = Data(value.utf8)
        }
        
        func encode(_ value: Double) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: Float) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: Int) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: Int8) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: Int16) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: Int32) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: Int64) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: UInt) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: UInt8) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: UInt16) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: UInt32) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        func encode(_ value: UInt64) throws {
            var primativeValue = value
            data = Data(bytes: &primativeValue, count: MemoryLayout.size(ofValue: value))
        }
        
        /// Unkeyed containers are unsupported by this encoder.
        struct UnsupportedUnkeyedCodingContainer: UnkeyedEncodingContainer {
            
            let codingPath: [CodingKey] = []
            let count: Int = 0
            var parent: EncoderImplementation
            
            mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
                return KeyedEncodingContainer<NestedKey>(UnsupportedKeyedCodingContainer<NestedKey>(parent: parent))
            }
            
            mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
                return UnsupportedUnkeyedCodingContainer(parent: parent)
            }
            
            mutating func superEncoder() -> Encoder {
                return parent
            }
            
            mutating func encodeNil() throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Bool) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: String) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Double) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Float) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int8) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int16) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int32) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int64) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt8) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt16) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt32) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt64) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode<T>(_ value: T) throws where T : Encodable {
                throw Error.unsupportedValue
            }
            
        }
        
        struct UnsupportedKeyedCodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
            let codingPath: [CodingKey] = []
            var parent: EncoderImplementation
            
            mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
                return KeyedEncodingContainer<NestedKey>(UnsupportedKeyedCodingContainer<NestedKey>(parent: parent))
            }
            
            mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
                return UnsupportedUnkeyedCodingContainer(parent: parent)
            }
            
            mutating func superEncoder() -> Encoder {
                return parent
            }
            
            mutating func superEncoder(forKey key: Key) -> Encoder {
                return parent
            }
            
            mutating func encodeNil(forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Bool, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: String, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Double, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Float, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int8, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int16, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int32, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: Int64, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt8, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt16, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt32, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode(_ value: UInt64, forKey key: Key) throws {
                throw Error.unsupportedContainerType
            }
            
            mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
                throw Error.unsupportedContainerType
            }
            
        }
        
    }
    
}


// MARK: - DataDecoder

/// An Decoder that serves as a `Data` passthrough.
/// Supports decoding a `Data` or primative type from the `singleValueContainer`.
public struct DataDecoder {
    
    public init() { }
    
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        return try T(from: DecoderImplementation(data: data))
    }
    
    enum Error: LocalizedError {
        case unsupportedContainerType
        case unsupportedValue
        
        var localizedDescription: String {
            switch self {
            case .unsupportedContainerType:
                return "Unsupported container type. DataDecoder only supports `singleValueContainer`."
            case .unsupportedValue:
                return "Could not covert the encoded value to `Data`."
            }
        }
    }
    
    struct DecoderImplementation: Decoder, SingleValueDecodingContainer {
        
        let data: Data
        let codingPath: [CodingKey] = []
        let userInfo: [CodingUserInfoKey : Any] = [:]
        
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            return self
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            return UnsupportedUnkeyedDecodingContainer(parent: self)
        }
        
        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            return KeyedDecodingContainer<Key>(UnsupportedKeyedDecodingContainer<Key>(parent: self))
        }
        
        func decodeNil() -> Bool {
            return false
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: String.Type) throws -> String {
            if let decodedString = String(data: data, encoding: .utf8) {
                return decodedString
            } else {
                throw Error.unsupportedValue
            }
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            return data.withUnsafeBytes { $0.pointee }
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            if let castedData = data as? T {
                return castedData
            } else {
                throw Error.unsupportedValue
            }
        }
        
        struct UnsupportedUnkeyedDecodingContainer: UnkeyedDecodingContainer {
            let codingPath: [CodingKey] = []
            let count: Int? = 0
            let isAtEnd: Bool = true
            let currentIndex: Int = 0
            var parent: DecoderImplementation
            
            mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
                return KeyedDecodingContainer<NestedKey>(UnsupportedKeyedDecodingContainer<NestedKey>(parent: parent))
            }
            
            mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
                return UnsupportedUnkeyedDecodingContainer(parent: parent)
            }
            
            mutating func superDecoder() throws -> Decoder {
                return parent
            }
            
            mutating func decodeNil() throws -> Bool {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: Bool.Type) throws -> Bool {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: String.Type) throws -> String {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: Double.Type) throws -> Double {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: Float.Type) throws -> Float {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: Int.Type) throws -> Int {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: Int8.Type) throws -> Int8 {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: Int16.Type) throws -> Int16 {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: Int32.Type) throws -> Int32 {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: Int64.Type) throws -> Int64 {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: UInt.Type) throws -> UInt {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
                throw Error.unsupportedContainerType
            }
            
            mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
                throw Error.unsupportedContainerType
            }
            
        }
        
        struct UnsupportedKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
            let codingPath: [CodingKey] = []
            let allKeys: [Key] = []
            var parent: DecoderImplementation
            
            func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
                return KeyedDecodingContainer<NestedKey>(UnsupportedKeyedDecodingContainer<NestedKey>(parent: parent))
            }
            
            func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
                return UnsupportedUnkeyedDecodingContainer(parent: parent)
            }
            
            func superDecoder() throws -> Decoder {
                return parent
            }
            
            func superDecoder(forKey key: Key) throws -> Decoder {
                return parent
            }
            
            func contains(_ key: Key) -> Bool {
                return false
            }
            
            func decodeNil(forKey key: Key) throws -> Bool {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: String.Type, forKey key: Key) throws -> String {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
                throw Error.unsupportedContainerType
            }
            
            func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
                throw Error.unsupportedContainerType
            }
            
            func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
                throw Error.unsupportedContainerType
            }
            
        }
        
    }
    
}

