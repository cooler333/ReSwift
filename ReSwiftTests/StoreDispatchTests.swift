//
//  StoreDispatchTests.swift
//  ReSwift
//
//  Created by Karl Bowden on 20/07/2016.
//  Copyright © 2016 ReSwift Community. All rights reserved.
//

import XCTest
@testable import ReSwift

class StoreDispatchTests: XCTestCase {

    typealias TestSubscriber = TestStoreSubscriber<TestAppState>
    typealias CallbackSubscriber = CallbackStoreSubscriber<TestAppState>

    var store: Store<TestAppState, Action>!
    var reducer: TestReducer!

    override func setUp() {
        super.setUp()
        reducer = TestReducer()
        store = Store(
            reducer: reducer.handleAction,
            state: TestAppState(),
            initialAction: .initial
        )
    }

    /**
     it throws an exception when a reducer dispatches an action
     */
    func testThrowsExceptionWhenReducersDispatch() {
        // Expectation lives in the `DispatchingReducer` class
        let reducer = DispatchingReducer()
        store = Store(
            reducer: reducer.handleAction,
            state: TestAppState(),
            initialAction: .initial
        )
        reducer.store = store
        store.dispatch(.setValueAction(10))
    }
}

// Needs to be class so that shared reference can be modified to inject store
class DispatchingReducer: XCTestCase {
    var store: Store<TestAppState, Action>?

    func handleAction(action: Action, state: TestAppState?) -> TestAppState {
        expectFatalError {
            self.store?.dispatch(.setValueAction(20))
        }
        return state ?? TestAppState()
    }
}
