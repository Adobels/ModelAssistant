/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file defines the OperationObserver protocol.
 */

import Foundation

/**
 The protocol that types may implement if they wish to be notified of significant
 operation lifecycle events.
 */
protocol OperationObserver {

    /// Invoked immediately prior to the `AOperation`'s `execute()` method.
    func operationDidStart(_ operation: AOperation)

    /// Invoked when `AOperation.produceOperation(_:)` is executed.
    func operation(_ operation: AOperation, didProduceOperation newOperation: Foundation.Operation)

    /**
     Invoked as an `AOperation` finishes, along with any errors produced during
     execution (or readiness evaluation).
     */
    func operationDidFinish(_ operation: AOperation, errors: [NSError])

}

