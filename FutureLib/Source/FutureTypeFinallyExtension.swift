//
//  FutureTypeFinallyExtension.swift
//  FutureLib
//
//  Copyright © 2015 Andreas Grosam. All rights reserved.
//


// MARK: - finally

extension FutureType {

    public final func finally(
        ec: ExecutionContext = GCDAsyncExecutionContext(),
        _ ct: CancellationTokenType = CancellationTokenNone(),
        f: ResultType -> ()) {
        onComplete(ec: ec, ct: ct, f: f)
    }


    //@warn_unused_result (message="Not using the returned future may prevent the continuation to be called.")
    public final func finally<U>(
        ec: ExecutionContext = GCDAsyncExecutionContext(),
        _ ct: CancellationTokenType = CancellationTokenNone(),
        f: ResultType -> U)
        -> Future<U> {
        let returnedFuture = Future<U>()
        onComplete(ec: ec, ct: ct) { [weak returnedFuture] result in
            // Caution: the mapping function must be called even when the returned
            // future has been deinitialized prematurely!
            let v = f(result)
            returnedFuture?.complete(Result(v))
        }
        return returnedFuture
    }


    //@warn_unused_result (message="Not using the returned future may prevent the continuation to be called.")
    public final func finally<U>(
        ec: ExecutionContext = GCDAsyncExecutionContext(),
        _ ct: CancellationTokenType = CancellationTokenNone(),
        f: ResultType throws -> U)
        -> Future<U> {
        let returnedFuture = Future<U>()
        onComplete(ec: ec, ct: ct) { [weak returnedFuture] result in
            // Caution: the mapping function must be called even when the returned
            // future has been deinitialized prematurely!
            do {
                let v = try f(result)
                returnedFuture?.complete(Result<U>(v))
            } catch let error {
                returnedFuture?.complete(Result<U>(error: error))
            }
        }
        return returnedFuture
    }


    //@warn_unused_result (message="Not using the returned future may prevent the continuation to be called.")
    public final func finally<U>(
        ec: ExecutionContext = GCDAsyncExecutionContext(),
        _ ct: CancellationTokenType = CancellationTokenNone(),
        f: ResultType -> Future<U>)
        -> Future<U> {
        let returnedFuture = Future<U>()
        onComplete(ec: SynchronousCurrent(), ct: ct) { [weak returnedFuture] result -> () in
            // Caution: the mapping function must be called even when the returned
            // future has been deinitialized prematurely!
            ec.schedule({ return f(result) }) { future in
                returnedFuture?.completeWith(future)
            }
        }
        return returnedFuture
    }


}
