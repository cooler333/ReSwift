//
//  StoreMiddlewareTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/24/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

import XCTest
@testable import ReSwift

let firstMiddleware: Middleware<Any, Action> = { dispatch, getState in
    return { next in
        return { action in
            switch action {
            case .setValueStringAction(let value):
                next(.setValueStringAction(value + " First Middleware"))

            default:
                next(action)
            }
        }
    }
}

let secondMiddleware: Middleware<Any, Action> = { dispatch, getState in
    return { next in
        return { action in
            switch action {
            case .setValueStringAction(let value):
                next(.setValueStringAction(value + " Second Middleware"))

            default:
                next(action)
            }
        }
    }
}

let dispatchingMiddleware: Middleware<Any, Action> = { dispatch, getState in
    return { next in
        return { action in
            if case let .setValueAction(value) = action {
                dispatch(.setValueStringAction("\(value ?? 0)"))
            }

            next(action)
        }
    }
}

let stateAccessingMiddleware: Middleware<TestStringAppState, Action> = { dispatch, getState in
    return { next in
        return { action in
            let appState = getState()

            // avoid endless recursion by checking if we've dispatched exactly this action
            if
                appState?.testValue == "OK",
                case let .setValueStringAction(value) = action,
                value != "Not OK"
            {
                // dispatch a new action
                dispatch(.setValueStringAction("Not OK"))

                // and swallow the current one
                next(.noOpAction)
            } else {
                next(action)
            }
        }
    }
}

func middleware(executing block: @escaping () -> Void) -> Middleware<Any, Action> {
    return { dispatch, getState in
        return { next in
            return { action in
                block()
            }
        }
    }
}

class StoreMiddlewareTests: XCTestCase {

    /**
     it can decorate dispatch function
     */
    func testDecorateDispatch() {
        let reducer = TestValueStringReducer()
        // Swift 4.1 fails to cast this from Middleware<StateType> to Middleware<TestStringAppState>
        // as expected during runtime, see: <https://bugs.swift.org/browse/SR-7362>
        let middleware: [Middleware<TestStringAppState, Action>] = [
            firstMiddleware,
            secondMiddleware
        ]
        let store = Store<TestStringAppState, Action>(
            reducer: reducer.handleAction,
            state: TestStringAppState(),
            initialAction: .initial,
            middleware: middleware
        )

        let subscriber = TestStoreSubscriber<TestStringAppState>()
        store.subscribe(subscriber)

        store.dispatch(.setValueStringAction("OK"))

        XCTAssertEqual(store.state.testValue, "OK First Middleware Second Middleware")
    }

    /**
     it can dispatch actions
     */
    func testCanDispatch() {
        let reducer = TestValueStringReducer()
        // Swift 4.1 fails to cast this from Middleware<StateType> to Middleware<TestStringAppState>
        // as expected during runtime, see: <https://bugs.swift.org/browse/SR-7362>
        let middleware: [Middleware<TestStringAppState, Action>] = [
            firstMiddleware,
            secondMiddleware,
            dispatchingMiddleware
        ]
        let store = Store<TestStringAppState, Action>(
            reducer: reducer.handleAction,
            state: TestStringAppState(),
            initialAction: .initial,
            middleware: middleware
        )

        let subscriber = TestStoreSubscriber<TestStringAppState>()
        store.subscribe(subscriber)

        store.dispatch(.setValueAction(10))

        XCTAssertEqual(store.state.testValue, "10 First Middleware Second Middleware")
    }

    /**
     it middleware can access the store's state
     */
    func testMiddlewareCanAccessState() {
        let reducer = TestValueStringReducer()
        var state = TestStringAppState()
        state.testValue = "OK"

        let store = Store<TestStringAppState, Action>(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial,
            middleware: [stateAccessingMiddleware]
        )

        store.dispatch(.setValueStringAction("Action That Won't Go Through"))

        XCTAssertEqual(store.state.testValue, "Not OK")
    }

    func testCanMutateMiddlewareAfterInit() {

        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store<TestStringAppState, Action>(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial,
            middleware: []
        )

        // Adding
        var added = false
        store.middleware.append(middleware(executing: { added = true }))
        store.dispatch(.setValueStringAction(""))
        XCTAssertTrue(added)

        // Removing
        added = false
        store.middleware = []
        store.dispatch(.setValueStringAction(""))
        XCTAssertFalse(added)
    }
}
