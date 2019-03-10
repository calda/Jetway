//
//  Promise.swift
//  Jetway
//
//  Adapted from PromiseKit by Soroush Khanlou.
//

import Foundation
#if os(Linux)
import Dispatch
#endif

public protocol ExecutionContext {
    func execute(_ work: @escaping () -> Void)
}

extension DispatchQueue: ExecutionContext {
    public func execute(_ work: @escaping () -> Void) {
        self.async(execute: work)
    }
}

public final class InvalidatableQueue: ExecutionContext {
    
    private var valid = true
    
    private let queue: DispatchQueue
    
    public init(queue: DispatchQueue = .main) {
        self.queue = queue
    }
    
    public func invalidate() {
        valid = false
    }
    
    public func execute(_ work: @escaping () -> Void) {
        guard valid else { return }
        self.queue.async(execute: work)
    }
    
}

struct Callback<Value> {
    let onFulfilled: (Value) -> ()
    let onRejected: (Error) -> ()
    let queue: ExecutionContext
    let isCatchCallback: Bool
    
    func callFulfill(_ value: Value) {
        queue.execute({
            self.onFulfilled(value)
        })
    }
    
    func callReject(_ error: Error) {
        queue.execute({
            self.onRejected(error)
        })
    }
}

enum State<Value>: CustomStringConvertible {
    
    /// The promise has not completed yet.
    /// Will transition to either the `fulfilled` or `rejected` state.
    case pending
    
    /// The promise now has a value.
    /// Will not transition to any other state.
    case fulfilled(value: Value)
    
    /// The promise failed with the included error.
    /// Will not transition to any other state.
    case rejected(error: Error)
    
    
    var isPending: Bool {
        if case .pending = self {
            return true
        } else {
            return false
        }
    }
    
    var isFulfilled: Bool {
        if case .fulfilled = self {
            return true
        } else {
            return false
        }
    }
    
    var isRejected: Bool {
        if case .rejected = self {
            return true
        } else {
            return false
        }
    }
    
    var value: Value? {
        if case let .fulfilled(value) = self {
            return value
        }
        return nil
    }
    
    var error: Error? {
        if case let .rejected(error) = self {
            return error
        }
        return nil
    }
    
    
    var description: String {
        switch self {
        case .fulfilled(let value):
            return "Fulfilled (\(value))"
        case .rejected(let error):
            return "Rejected (\(error))"
        case .pending:
            return "Pending"
        }
    }
}


public enum RejectedPromise {
    public typealias Purpose = String
    
    /// If the current promise doesn't have an associated catch block,
    /// this block will be called upon the rejection of the promise.
    public static var fallbackCatchBlock: ((Purpose, Error) -> Void)?
}

public final class Promise<Value> {
    
    private var state: State<Value>
    private let lockQueue = DispatchQueue(label: "promise_lock_queue", qos: .userInitiated)
    private var callbacks: [Callback<Value>] = []
    private let purpose: String
    
    public init(purpose: String) {
        state = .pending
        self.purpose = purpose
    }
    
    public init(value: Value) {
        state = .fulfilled(value: value)
        purpose = "Fulfilled Promise (\(value))"
    }
    
    public init(error: Error) {
        state = .rejected(error: error)
        purpose = "Rejected Promise (\(error))"
    }
    
    public convenience init(purpose: String, queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated), work: @escaping (_ fulfill: @escaping (Value) -> (), _ reject: @escaping (Error) -> () ) throws -> ()) {
        self.init(purpose: purpose)
        queue.async(execute: {
            do {
                try work(self.fulfill, self.reject)
            } catch let error {
                self.reject(error)
            }
        })
    }
    
    /// - note: This one is "flatMap"
    @discardableResult
    public func then<NewValue>(on queue: ExecutionContext = DispatchQueue.main, _ onFulfilled: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue>(purpose: "Child of \(self.purpose)", work: { fulfill, reject in
            self.addCallbacks(
                on: queue,
                onFulfilled: { value in
                    do {
                        try onFulfilled(value).then(on: queue, fulfill, reject)
                    } catch let error {
                        reject(error)
                    }
            },
                onRejected: reject
            )
        })
    }
    
    /// - note: This one is "map"
    @discardableResult
    public func then<NewValue>(on queue: ExecutionContext = DispatchQueue.main, _ onFulfilled: @escaping (Value) throws -> NewValue) -> Promise<NewValue> {
        return then(on: queue, { (value) -> Promise<NewValue> in
            do {
                return Promise<NewValue>(value: try onFulfilled(value))
            } catch let error {
                return Promise<NewValue>(error: error)
            }
        })
    }
    
    @discardableResult
    public func then(on queue: ExecutionContext = DispatchQueue.main, _ onFulfilled: ((Value) -> ())?, _ onRejected: ((Error) -> ())?) -> Promise<Value> {
        addCallbacks(on: queue, onFulfilled: onFulfilled, onRejected: onRejected)
        return self
    }
    
    @discardableResult
    public func `catch`(on queue: ExecutionContext = DispatchQueue.main, _ onRejected: @escaping (Error) -> ()) -> Promise<Value> {
        return then(on: queue, nil, onRejected)
    }
    
    @discardableResult
    public func and<T>(_ addition: T, on queue: ExecutionContext = DispatchQueue.main) -> Promise<(Value, T)> {
        let combinedPromise = Promise<(Value, T)>(purpose: "Child (and) of \(self.purpose)")
        
        self.then(on: queue, { value in
            combinedPromise.fulfill((value, addition))
        }).catch(on: queue, { error in
            combinedPromise.reject(error)
        })
        
        return combinedPromise
    }
    
    @discardableResult
    public func transform<T>(to result: T, on queue: ExecutionContext = DispatchQueue.main) -> Promise<T> {
        let transformedPromise = Promise<T>(purpose: "Child (transform) of \(self.purpose)")
        
        self.then(on: queue, { value in
            transformedPromise.fulfill(result)
        }).catch(on: queue, { error in
            transformedPromise.reject(error)
        })
        
        return transformedPromise
    }
    
    public func reject(_ error: Error) {
        updateState(.rejected(error: error))
    }
    
    public func fulfill(_ value: Value) {
        updateState(.fulfilled(value: value))
    }
    
    public var isPending: Bool {
        return !isFulfilled && !isRejected
    }
    
    public var isFulfilled: Bool {
        return value != nil
    }
    
    public var isRejected: Bool {
        return error != nil
    }
    
    public var value: Value? {
        return lockQueue.sync(execute: {
            return self.state.value
        })
    }
    
    public var error: Error? {
        return lockQueue.sync(execute: {
            return self.state.error
        })
    }
    
    private func updateState(_ state: State<Value>) {
        guard self.isPending else { return }
        lockQueue.sync(execute: {
            self.state = state
        })
        fireCallbacksIfCompleted()
    }
    
    private func addCallbacks(on queue: ExecutionContext = DispatchQueue.main, onFulfilled: ((Value) -> ())?, onRejected: ((Error) -> ())?) {
        
        let callback = Callback(
            onFulfilled: onFulfilled ?? { _ in },
            onRejected: onRejected ?? { _ in },
            queue: queue,
            isCatchCallback: (onRejected != nil))
        
        lockQueue.async(execute: {
            self.callbacks.append(callback)
        })
        
        fireCallbacksIfCompleted()
    }
    
    private func fireCallbacksIfCompleted() {
        lockQueue.async(execute: {
            
            guard !self.state.isPending else { return }
            
            self.callbacks.forEach { callback in
                switch self.state {
                case let .fulfilled(value):
                    callback.callFulfill(value)
                case let .rejected(error):
                    callback.callReject(error)
                default:
                    break
                }
            }
            
            if case .rejected(let error) = self.state,
                !self.callbacks.contains(where: { $0.isCatchCallback })
            {
                RejectedPromise.fallbackCatchBlock?(self.purpose, error)
            }
            
            self.callbacks.removeAll()
        })
    }
}
