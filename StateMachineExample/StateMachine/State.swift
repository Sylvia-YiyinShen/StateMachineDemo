//
//  State.swift
//  StateMachineExample
//
//  Created by Yiyin Shen on 11/6/19.
//  Copyright © 2019 Sylvia. All rights reserved.
//

class State<T> where T: StateIdentifier {
    let identifier: T
    private let allowedTransitions: Set<T>

    var willExit: ((T) -> Void)?
    var didEnter: ((T) -> Void)?

    init(identifier: T, allowedTransitions: T...) {
        self.identifier = identifier
        self.allowedTransitions = Set(allowedTransitions)
    }

    func canTransition(to state: T) -> Bool {
        return allowedTransitions.contains(state)
    }
}

extension State: Equatable {
    static func == (lhs: State, rhs: State) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

protocol StateIdentifier: Hashable {}
