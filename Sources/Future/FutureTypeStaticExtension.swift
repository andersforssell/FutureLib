//
//  FutureTypeStaticExtension.swift
//  FutureLib
//
//  Copyright © 2015 Andreas Grosam. All rights reserved.
//




/**
 A couple of convenience methods which return a completed future without
 requiring a promise object.
 */
extension FutureType {
    
    /**
     Returns a future which will be completed with the result of function `f`.
     Function `f` will be asynchronously executed on the given execution context. 
     
     If the function `f` throws an error, the returned future will be completed
     with the same error.
     
     - parameter ec: An execution context where the function `f` will be executed.
     - parameter f: A function with signature `() throws -> T`.
     - returns: A `Future` whose `ValueType` equals the return type of the function 
     `f`.
     */
    static public func apply<ValueType>(ec: ExecutionContext = ConcurrentAsync(),
        f: () throws -> ValueType)
        -> Future<ValueType> 
    {
        let returnedFuture: Future<ValueType> = Future<ValueType>()
        ec.execute() { 
            returnedFuture.complete(Try(f))
        }
        return returnedFuture
    }
    

    /**
     Creates a future which is completed with `error`.
     - parameter error: The error with which the future will be completed.
     - returns: A completed future.
     */
    static public func failed(error: ErrorType) -> Future<ValueType> {
        return Future<ValueType>(error: error)
    }


    /**
     Creates a future which is completed with `value`.
     - parameter value: The value with which the future will be completed.
     - returns: A completed future.
     */
    static public func succeeded(value: ValueType) -> Future<ValueType> {
        return Future<ValueType>(value: value)
    }

    /**
     Creates a future which is completed with the given `Try`.
     - parameter result: The result of type `Try<T>` with which the future will be completed.
     - returns: A completed future.
     */
    static public func completed(result: Try<ValueType>) -> Future<ValueType> {
        return Future<ValueType>(result: result)
    }
    
    
    

    /**
     Creates a pending future which will be completed with the given error after
     the specified delay. If there is a cancellation requested before the delay
     expires, the returned future will be completed with `CancellationError.Cancelled`.

     - parameter delay: The delay in seconds.
     - parameter cancellationToken: A cancellation token which will be monitored.
     - parameter error: The error with which the future will be completed after the delay.
     - returns: A new future.
     */
    static public func failedAfter(delay: Double,
        cancellationToken: CancellationTokenType = CancellationTokenNone(),
        error: ErrorType)
        -> Future<ValueType> {
        let returnedFuture = Future<ValueType>()
        let cid = cancellationToken.onCancel(on: GCDAsyncExecutionContext()) {
            returnedFuture.complete(Try<ValueType>(error: CancellationError.Cancelled))
        }
        // Perhaps, we should capture returnedFuture weakly?!
        let timer = Timer(delay: delay, tolerance: 0, cancellationToken: cancellationToken) { _ in
            returnedFuture.complete(Try<ValueType>(error: error))
            cancellationToken.unregister(cid)
        }
        timer.resume()
        return returnedFuture
    }


    /**
     Creates a pending future which will be completed with the given value after
     the specified delay. If there is a cancellation requested before the delay
     expires, the returned future will be completed with `CancellationError.Cancelled`.

     - parameter delay: The delay in seconds.
     - parameter cancellationToken: A cancellation token which will be monitored.
     - parameter value: The value with which the future will be completed after the delay.
     - returns: A future.
     */
    static public func succeededAfter(delay: Double,
        cancellationToken: CancellationTokenType = CancellationTokenNone(),
        value: ValueType)
        -> Future<ValueType> {
        let returnedFuture = Future<ValueType>()
        let cid = cancellationToken.onCancel(on: GCDAsyncExecutionContext()) {
            returnedFuture.complete(Try<ValueType>(error: CancellationError.Cancelled))
        }
        // Perhaps, we should capture returnedFuture weakly?!
        let timer = Timer(delay: delay, tolerance: 0, cancellationToken: cancellationToken) { _ in
            returnedFuture.complete(Try<ValueType>(value))
            cancellationToken.unregister(cid)
        }
        timer.resume()
        return returnedFuture
    }

}
