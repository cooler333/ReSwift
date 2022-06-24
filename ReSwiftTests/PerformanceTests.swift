//  Copyright © 2019 ReSwift Community. All rights reserved.

import XCTest
import ReSwift

final class PerformanceTests: XCTestCase {
    struct MockState {}
    enum MockAction {
        case initial
        case noOpAction
    }

    let subscribers: [MockSubscriber] = (0..<3000).map { _ in MockSubscriber() }
    let store = Store<MockState, MockAction>(
        reducer: { _, state in return state ?? MockState() },
        state: MockState(),
        initialAction: .initial,
        automaticallySkipsRepeats: false
    )

    class MockSubscriber: StoreSubscriber {
        func newState(state: MockState) {
            // Do nothing
        }
    }

    func testNotify() {
        self.subscribers.forEach(self.store.subscribe)
        self.measure {
            self.store.dispatch(.noOpAction)
        }
    }

    func testSubscribe() {
        self.measure {
            self.subscribers.forEach(self.store.subscribe)
        }
    }
}
