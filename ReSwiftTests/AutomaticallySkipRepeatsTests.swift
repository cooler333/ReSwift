//
//  AutomaticallySkipRepeatsTests.swift
//  ReSwift
//
//  Created by Daniel Martín Prieto on 03/11/2017.
//  Copyright © 2017 ReSwift Community. All rights reserved.
//
import XCTest
import ReSwift

class AutomaticallySkipRepeatsTests: XCTestCase {

    private var store: Store<State, ChangeAgeAction>!
    private var subscriptionUpdates: Int = 0

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        store = Store<State, ChangeAgeAction>(
            reducer: reducer,
            state: nil,
            initialAction: .initial
        )
        subscriptionUpdates = 0
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        store = nil
        subscriptionUpdates = 0
        super.tearDown()
    }

    func testInitialSubscriptionWithRegularSubstateSelection() {
        store.subscribe(self) { $0.select { $0.name } }
        XCTAssertEqual(self.subscriptionUpdates, 1)
    }

    func testInitialSubscriptionWithKeyPath() {
        store.subscribe(self) { $0.select(\.name) }
        XCTAssertEqual(self.subscriptionUpdates, 1)
    }

    func testDispatchUnrelatedActionWithExplicitSkipRepeatsWithRegularSubstateSelection() {
        store.subscribe(self) { $0.select { $0.name }.skipRepeats() }
        XCTAssertEqual(self.subscriptionUpdates, 1)
        store.dispatch(.changeAge(30))
        XCTAssertEqual(self.subscriptionUpdates, 1)
    }

    func testDispatchUnrelatedActionWithExplicitSkipRepeatsWithKeyPath() {
        store.subscribe(self) { $0.select(\.name).skipRepeats() }
        XCTAssertEqual(self.subscriptionUpdates, 1)
        store.dispatch(.changeAge(30))
        XCTAssertEqual(self.subscriptionUpdates, 1)
    }

    func testDispatchUnrelatedActionWithoutExplicitSkipRepeatsWithRegularSubstateSelection() {
        store.subscribe(self) { $0.select { $0.name } }
        XCTAssertEqual(self.subscriptionUpdates, 1)
        store.dispatch(.changeAge(30))
        XCTAssertEqual(self.subscriptionUpdates, 1)
    }

    func testDispatchUnrelatedActionWithoutExplicitSkipRepeatsWithKeyPath() {
        store.subscribe(self) { $0.select(\.name) }
        XCTAssertEqual(self.subscriptionUpdates, 1)
        store.dispatch(.changeAge(30))
        XCTAssertEqual(self.subscriptionUpdates, 1)
    }

}

extension AutomaticallySkipRepeatsTests: StoreSubscriber {
    func newState(state: String) {
        subscriptionUpdates += 1
    }
}

private struct State {
    let age: Int
    let name: String
}

extension State: Equatable {
    static func == (lhs: State, rhs: State) -> Bool {
        return lhs.age == rhs.age && lhs.name == rhs.name
    }
}

enum ChangeAgeAction {
    case initial
    case changeAge(_ newAge: Int)
}

private let initialState = State(age: 29, name: "Daniel")

private func reducer(action: ChangeAgeAction, state: State?) -> State {
    let defaultState = state ?? initialState
    switch action {
    case .changeAge(let newAge):
        return State(age: newAge, name: defaultState.name)

    default:
        return defaultState
    }
}
