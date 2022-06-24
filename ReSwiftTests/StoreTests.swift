//
//  StoreTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

import XCTest
@testable import ReSwift

class StoreTests: XCTestCase {

    /**
     it dispatches an Init action when it doesn't receive an initial state
     */
    func testInit() {
        let reducer = MockReducer()
        _ = Store<CounterState, Action>(
            reducer: reducer.handleAction,
            state: nil,
            initialAction: .initial
        )

        let firstAction = reducer.calledWithAction[0]
        switch firstAction {
        case .initial:
            break
        default:
            XCTFail("First action must be `.initial`")
        }
    }

    /**
     it deinitializes when no reference is held
     */
    func testDeinit() {
        var deInitCount = 0

        autoreleasepool {
            let reducer = TestReducer()
            _ = DeInitStore(
                reducer: reducer.handleAction,
                state: TestAppState(),
                initialAction: .initial,
                deInitAction: { deInitCount += 1 })
        }

        XCTAssertEqual(deInitCount, 1)
    }

}

// Used for deinitialization test
class DeInitStore<State>: Store<State, Action> {
    var deInitAction: (() -> Void)?

    deinit {
        deInitAction?()
    }

    required convenience init(
        reducer: @escaping Reducer<State, Action>,
        state: State?,
        initialAction: ActionType,
        deInitAction: (() -> Void)?
    ) {
        self.init(
            reducer: reducer,
            state: state,
            initialAction: initialAction,
            middleware: [],
            automaticallySkipsRepeats: false)
        self.deInitAction = deInitAction
    }

    required init(
        reducer: @escaping Reducer<State, Action>,
        state: State?,
        initialAction: Action,
        middleware: [Middleware<State, Action>],
        automaticallySkipsRepeats: Bool
    ) {
        super.init(
            reducer: reducer,
            state: state,
            initialAction: .initial,
            middleware: middleware,
            automaticallySkipsRepeats: automaticallySkipsRepeats
        )
    }
}

struct CounterState {
    var count: Int = 0
}

class MockReducer {

    var calledWithAction: [Action] = []

    func handleAction(action: Action, state: CounterState?) -> CounterState {
        calledWithAction.append(action)

        return state ?? CounterState()
    }

}
