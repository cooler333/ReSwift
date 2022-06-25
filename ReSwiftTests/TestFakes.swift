//
//  TestFakes.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/24/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

import Foundation
@testable import ReSwift

struct TestAppState {
    var testValue: Int?

    init() {
        testValue = nil
    }
}

struct TestStringAppState {
    var testValue: String

    init() {
        testValue = "Initial"
    }
}

extension TestStringAppState: Equatable {
    static func == (lhs: TestStringAppState, rhs: TestStringAppState) -> Bool {
        return lhs.testValue == rhs.testValue
    }
}

struct TestNonEquatable {
    var testValue: NonEquatable

    init() {
        testValue = NonEquatable()
    }
}

struct NonEquatable {
    var testValue: String

    init() {
        testValue = "Initial"
    }
}

struct TestCustomAppState {
    var substate: TestCustomSubstate

    init(substate: TestCustomSubstate) {
        self.substate = substate
    }

    init(substateValue value: Int = 0) {
        self.substate = TestCustomSubstate(value: value)
    }

    struct TestCustomSubstate {
        var value: Int
    }
}

enum Action {
    case initial
    case noOpAction
    case setValueAction(_ value: Int?)
    case setValueStringAction(_ value: String)
    case setCustomSubstateAction(_ value: Int)
    case setNonEquatableAction(_ value: NonEquatable)
    case setOtherStateAction(_ otherState: OtherState)
    case tracerAction
}

struct TestReducer {
    func handleAction(action: Action, state: TestAppState?) -> TestAppState {
        var state = state ?? TestAppState()

        switch action {
        case .setValueAction(let value):
            state.testValue = value
            return state
        default:
            return state
        }
    }
}

struct TestValueStringReducer {
    func handleAction(action: Action, state: TestStringAppState?) -> TestStringAppState {
        var state = state ?? TestStringAppState()

        switch action {
        case .setValueStringAction(let value):
            state.testValue = value
            return state
        default:
            return state
        }
    }
}

struct TestCustomAppStateReducer {
    func handleAction(action: Action, state: TestCustomAppState?) -> TestCustomAppState {
        var state = state ?? TestCustomAppState()

        switch action {
        case .setCustomSubstateAction(let value):
            state.substate.value = value
            return state
        default:
            return state
        }
    }
}

struct TestNonEquatableReducer {
    func handleAction(action: Action, state: TestNonEquatable?) -> TestNonEquatable {
        var state = state ?? TestNonEquatable()

        switch action {
        case .setNonEquatableAction(let value):
            state.testValue = value
            return state

        default:
            return state
        }
    }
}

class TestStoreSubscriber<T>: StoreSubscriber {
    var receivedStates: [T] = []

    func newState(state: T) {
        receivedStates.append(state)
    }
}

class BlockSubscriber<S>: StoreSubscriber {
    typealias StoreSubscriberStateType = S
    private let block: (S) -> Void

    init(block: @escaping (S) -> Void) {
        self.block = block
    }

    func newState(state: S) {
        self.block(state)
    }
}

class DispatchingSubscriber: StoreSubscriber {
    var store: Store<TestAppState, Action>

    init(store: Store<TestAppState, Action>) {
        self.store = store
    }

    func newState(state: TestAppState) {
        // Test if we've already dispatched this action to
        // avoid endless recursion
        if state.testValue != 5 {
            self.store.dispatch(.setValueAction(5))
        }
    }
}

class CallbackStoreSubscriber<T>: StoreSubscriber {

    let handler: (T) -> Void

    init(handler: @escaping (T) -> Void) {
        self.handler = handler
    }

    func newState(state: T) {
        handler(state)
    }
}
