//
//  StoreSubscriberTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 1/23/16.
//  Copyright © 2016 ReSwift Community. All rights reserved.
//

import XCTest
@testable import ReSwift

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class StoreSubscriberTests: XCTestCase {

    /**
     it allows to pass a state selector closure
     */
    func testAllowsSelectorClosure() {
        let reducer = TestReducer()
        let store = Store(
            reducer: reducer.handleAction,
            state: TestAppState(),
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<Int?>()

        store.subscribe(subscriber) {
            $0.select { $0.testValue }
        }

        store.dispatch(.setValueAction(3))

        XCTAssertEqual(subscriber.receivedValue, 3)

        store.dispatch(.setValueAction(nil))

        XCTAssertEqual(subscriber.receivedValue, .some(.none))
    }

    /**
     it allows to pass a state selector key path
     */
    func testAllowsSelectorKeyPath() {
        let reducer = TestReducer()
        let store = Store(
            reducer: reducer.handleAction,
            state: TestAppState(),
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<Int?>()

        store.subscribe(subscriber) {
            $0.select(\.testValue)
        }

        store.dispatch(.setValueAction(3))

        XCTAssertEqual(subscriber.receivedValue, 3)

        store.dispatch(.setValueAction(nil))

        XCTAssertEqual(subscriber.receivedValue, .some(.none))
    }

    /**
     it supports complex state selector closures
     */
    func testComplexStateSelector() {
        let reducer = TestComplexAppStateReducer()
        let store = Store(
            reducer: reducer.handleAction,
            state: TestComplexAppState(),
            initialAction: .initial
        )
        let subscriber = TestSelectiveSubscriber()

        store.subscribe(subscriber) {
            $0.select {
                ($0.testValue, $0.otherState?.name)
            }
        }
        store.dispatch(.setValueAction(5))
        store.dispatch(.setOtherStateAction(
            OtherState(name: "TestName", age: 99)
        ))

        XCTAssertEqual(subscriber.receivedValue.0, 5)
        XCTAssertEqual(subscriber.receivedValue.1, "TestName")
    }

    /**
     it does not notify subscriber for unchanged substate state when using `skipRepeats`.
     */
    func testUnchangedStateWithRegularSubstateSelection() {
        let reducer = TestReducer()
        var state = TestAppState()
        state.testValue = 3
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<Int?>()

        store.subscribe(subscriber) {
            $0
            .select { $0.testValue }
            .skipRepeats { $0 == $1 }
        }

        XCTAssertEqual(subscriber.receivedValue, 3)

        store.dispatch(.setValueAction(3))

        XCTAssertEqual(subscriber.receivedValue, 3)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testUnchangedStateWithKeyPath() {
        let reducer = TestReducer()
        var state = TestAppState()
        state.testValue = 3
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<Int?>()

        store.subscribe(subscriber) {
            $0
            .select(\.testValue)
            .skipRepeats { $0 == $1 }
        }

        XCTAssertEqual(subscriber.receivedValue, 3)

        store.dispatch(.setValueAction(3))

        XCTAssertEqual(subscriber.receivedValue, 3)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    /**
     it does not notify subscriber for unchanged substate state when using the default
     `skipRepeats` implementation.
     */
    func testUnchangedStateDefaultSkipRepeatsWithRegularSubstateSelection() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<String>()

        store.subscribe(subscriber) {
            $0
            .select { $0.testValue }
            .skipRepeats()
        }

        XCTAssertEqual(subscriber.receivedValue, "Initial")

        store.dispatch(.setValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testUnchangedStateDefaultSkipRepeatsWithKeyPath() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<String>()

        store.subscribe(subscriber) {
            $0
            .select(\.testValue)
            .skipRepeats()
        }

        XCTAssertEqual(subscriber.receivedValue, "Initial")

        store.dispatch(.setValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    /**
     it skips repeated state values by when `skipRepeats` returns `true`.
     */
    func testSkipsStateUpdatesForCustomEqualityChecksWithRegularSubstateSelection() {
        let reducer = TestCustomAppStateReducer()
        let state = TestCustomAppState(substateValue: 5)
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<TestCustomAppState.TestCustomSubstate>()

        store.subscribe(subscriber) {
            $0
            .select { $0.substate }
            .skipRepeats { $0.value == $1.value }
        }

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(.setCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testSkipsStateUpdatesForCustomEqualityChecksWithKeyPath() {
        let reducer = TestCustomAppStateReducer()
        let state = TestCustomAppState(substateValue: 5)
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<TestCustomAppState.TestCustomSubstate>()

        store.subscribe(subscriber) {
            $0
            .select(\.substate)
            .skipRepeats { $0.value == $1.value }
        }

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(.setCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testPassesOnDuplicateSubstateUpdatesByDefaultWithRegularSubstateSelection() {
        let reducer = TestNonEquatableReducer()
        let state = TestNonEquatable()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<NonEquatable>()

        store.subscribe(subscriber) {
            $0.select { $0.testValue }
        }

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(.setNonEquatableAction(NonEquatable()))

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 2)
    }

    func testPassesOnDuplicateSubstateUpdatesByDefaultWithKeyPath() {
        let reducer = TestNonEquatableReducer()
        let state = TestNonEquatable()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<NonEquatable>()

        store.subscribe(subscriber) {
            $0.select(\.testValue)
        }

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(.setNonEquatableAction(NonEquatable()))

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 2)
    }

    func testPassesOnDuplicateSubstateWhenSkipsFalseWithRegularSubstateSelection() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial,
            middleware: [],
            automaticallySkipsRepeats: false
        )
        let subscriber = TestFilteredSubscriber<String>()

        store.subscribe(subscriber) {
            $0.select { $0.testValue }
        }

        XCTAssertEqual(subscriber.receivedValue, "Initial")

        store.dispatch(.setValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 2)
    }

    func testPassesOnDuplicateSubstateWhenSkipsFalseWithKeyPath() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial,
            middleware: [],
            automaticallySkipsRepeats: false
        )
        let subscriber = TestFilteredSubscriber<String>()

        store.subscribe(subscriber) {
            $0.select(\.testValue)
        }

        XCTAssertEqual(subscriber.receivedValue, "Initial")

        store.dispatch(.setValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 2)
    }

    func testSkipsStateUpdatesForEquatableStateByDefault() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial,
            middleware: []
        )
        let subscriber = TestFilteredSubscriber<TestStringAppState>()

        store.subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(.setValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testSkipsStateUpdatesForEquatableSubStateByDefaultWithRegularSubstateSelection() {
        let reducer = TestNonEquatableReducer()
        let state = TestNonEquatable()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<String>()

        store.subscribe(subscriber) {
            $0.select { $0.testValue.testValue }
        }

        XCTAssertEqual(subscriber.receivedValue, "Initial")

        store.dispatch(.setValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testSkipsStateUpdatesForEquatableSubStateByDefaultWithKeyPathOnGenericStoreType() {
        let reducer = TestNonEquatableReducer()
        let state = TestNonEquatable()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )

        func runTests<S: StoreType>(store: S) where S.State == TestNonEquatable, S.ActionType == Action {
            let subscriber = TestFilteredSubscriber<String>()

            store.subscribe(subscriber) {
                $0.select(\.testValue.testValue)
            }

            XCTAssertEqual(subscriber.receivedValue, "Initial")

            store.dispatch(.setValueStringAction("Initial"))

            XCTAssertEqual(subscriber.receivedValue, "Initial")
            XCTAssertEqual(subscriber.newStateCallCount, 1)
        }

        runTests(store: store)
    }

    func testSkipsStateUpdatesForEquatableSubStateByDefaultWithKeyPath() {
        let reducer = TestNonEquatableReducer()
        let state = TestNonEquatable()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<String>()

        store.subscribe(subscriber) {
            $0.select(\.testValue.testValue)
        }

        XCTAssertEqual(subscriber.receivedValue, "Initial")

        store.dispatch(.setValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testPassesOnDuplicateStateUpdatesInCustomizedStore() {
        let reducer = TestValueStringReducer()
        let state = TestStringAppState()
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial,
            middleware: [],
            automaticallySkipsRepeats: false
        )
        let subscriber = TestFilteredSubscriber<TestStringAppState>()

        store.subscribe(subscriber)

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")

        store.dispatch(.setValueStringAction("Initial"))

        XCTAssertEqual(subscriber.receivedValue.testValue, "Initial")
        XCTAssertEqual(subscriber.newStateCallCount, 2)
    }

    func testSkipWhenWithRegularSubstateSelection() {
        let reducer = TestCustomAppStateReducer()
        let state = TestCustomAppState(substateValue: 5)
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<TestCustomAppState.TestCustomSubstate>()

        store.subscribe(subscriber) {
            $0
            .select { $0.substate }
            .skip { $0.value == $1.value }
        }

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(.setCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testSkipWhenWithKeyPath() {
        let reducer = TestCustomAppStateReducer()
        let state = TestCustomAppState(substateValue: 5)
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<TestCustomAppState.TestCustomSubstate>()

        store.subscribe(subscriber) {
            $0
            .select(\.substate)
            .skip { $0.value == $1.value }
        }

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(.setCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testOnlyWhenWithRegularSubstateSelection() {
        let reducer = TestCustomAppStateReducer()
        let state = TestCustomAppState(substateValue: 5)
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<TestCustomAppState.TestCustomSubstate>()

        store.subscribe(subscriber) {
            $0
            .select { $0.substate }
            .only { $0.value != $1.value }
        }

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(.setCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }

    func testOnlyWhenWithKeyPath() {
        let reducer = TestCustomAppStateReducer()
        let state = TestCustomAppState(substateValue: 5)
        let store = Store(
            reducer: reducer.handleAction,
            state: state,
            initialAction: .initial
        )
        let subscriber = TestFilteredSubscriber<TestCustomAppState.TestCustomSubstate>()

        store.subscribe(subscriber) {
            $0
            .select(\.substate)
            .only { $0.value != $1.value }
        }

        XCTAssertEqual(subscriber.receivedValue.value, 5)

        store.dispatch(.setCustomSubstateAction(5))

        XCTAssertEqual(subscriber.receivedValue.value, 5)
        XCTAssertEqual(subscriber.newStateCallCount, 1)
    }
}

class TestFilteredSubscriber<T>: StoreSubscriber {
    var receivedValue: T!
    var newStateCallCount = 0

    func newState(state: T) {
        receivedValue = state
        newStateCallCount += 1
    }

}

/**
 Example of how you can select a substate. The return value from
 `selectSubstate` and the argument for `newState` need to match up.
 */
class TestSelectiveSubscriber: StoreSubscriber {
    var receivedValue: (Int?, String?)

    func newState(state: (Int?, String?)) {
        receivedValue = state
    }
}

struct TestComplexAppState {
    var testValue: Int?
    var otherState: OtherState?
}

struct OtherState {
    var name: String?
    var age: Int?
}

struct TestComplexAppStateReducer {
    func handleAction(action: Action, state: TestComplexAppState?) -> TestComplexAppState {
        var state = state ?? TestComplexAppState()

        switch action {
        case .setValueAction(let value):
            state.testValue = value
            return state
        case .setOtherStateAction(let otherState):
            state.otherState = otherState
        default:
            break
        }

        return state
    }
}
