//
//  StateMachine.swift
//  StateMachineExample
//
//  Created by Yiyin Shen on 6/6/19.
//  Copyright © 2019 Sylvia. All rights reserved.
//

import Foundation

class StateMachine<T> where T: StateIdentifier {
    private var states: [State<T>]
    private var currentState: State<T>
    var state: State<T> {
        return currentState
    }
    init(firstState: State<T>, otherStates: State<T>...) {
        self.states = [firstState] + otherStates
        self.currentState = firstState
        firstState.didEnter?(firstState.identifier)
    }

    func transition(to stateIdentifier: T, completion: () -> Void) {
        guard let toState = findState(with: stateIdentifier) else {
            print("Unknown state")
            return
        }

        guard currentState.canTransition(to: stateIdentifier) else {
            print("\(currentState.identifier) -> \(stateIdentifier) Transition not allowed")
            return
        }

        let previousState = currentState

        if stateIdentifier == previousState.identifier {
            print("Already at state: \(state)")
        }

        currentState.willExit?(toState.identifier)
        toState.didEnter?(currentState.identifier)
        currentState = toState

        print("Transitioned from \(previousState.identifier) to \(currentState.identifier)")
        completion()
    }

    private func findState(with identifier: T) -> State<T>? {
        return states.first(where: { $0.identifier == identifier })
    }
}

