//
//  TypeHelperTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/20/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

import XCTest
/**
 @testable import for testing of `withSpecificTypes`
 */
@testable import ReSwift

struct AppState1 {}
struct AppState2 {}

class TypeHelperTests: XCTestCase {

    /**
     it calls methods if the source type can be casted into the function signature type
     */
    func testSourceTypeCasting() {
        var called = false
        let reducerFunction: (Action, AppState1?) -> AppState1 = { action, state in
            called = true

            return state ?? AppState1()
        }

        withSpecificTypes(.noOpAction, state: AppState1(), function: reducerFunction)

        XCTAssertTrue(called)
    }

    /**
     it calls the method if the source type is nil
     */
    func testCallsIfSourceTypeIsNil() {
        var called = false
        let reducerFunction: (Action, AppState1?) -> AppState1 = { action, state in
            called = true

            return state ?? AppState1()
        }

        withSpecificTypes(.noOpAction, state: nil, function: reducerFunction)

        XCTAssertTrue(called)
    }

    /**
     it doesn't call if source type can't be casted to function signature type
     */
    func testDoesntCallIfCastFails() {
        var called = false
        let reducerFunction: (Action, AppState1?) -> AppState1 = { action, state in
            called = true

            return state ?? AppState1()
        }

        withSpecificTypes(.noOpAction, state: AppState2(), function: reducerFunction)

        XCTAssertFalse(called)
    }
}
