//
//  ViewController.swift
//  StateMachineExample
//
//  Created by Yiyin Shen on 6/6/19.
//  Copyright © 2019 Sylvia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!

    private let LOGOUT_MESSAGE = "You have not signed in."
    private let LOGIN_MESSAGE = "Loading to open landing page..."

    private var signinStateMachine: StateMachine<SignInState>?
    private var mainWorkflowStateMachine: StateMachine<MainWorkflowState>?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureStateMachine()
    }

    private func configureStateMachine() {

        let logoutState = State<SignInState>(identifier: .logout, allowedTransitions: .login, .error)
        let loginState = State<SignInState>(identifier: .login, allowedTransitions: .logout)
        let loginErrorState = State<SignInState>(identifier: .error, allowedTransitions: .logout)
        signinStateMachine = StateMachine(firstState: logoutState, otherStates: loginState, loginErrorState)

        // controlling lifecycle of main work flow module
        loginState.didEnter = { [weak self] _ in
            let landingState = State<MainWorkflowState>(identifier: .landing, allowedTransitions: .list)
            landingState.didEnter = { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.messageLabel.text = "Now you are at landing page. You have signed in."
                }
            }
            let listState = State<MainWorkflowState>(identifier: .list, allowedTransitions: .detail)
            listState.didEnter  = {
                [weak self] _ in
                self?.messageLabel.text = "Now you are at list page. You have signed in."
            }
            let detailState = State<MainWorkflowState>(identifier: .detail, allowedTransitions: .list, .landing)
            self?.mainWorkflowStateMachine = StateMachine(firstState: landingState, otherStates: listState, detailState)

        }

        // controlling lifecycle of main work flow module
        loginState.willExit = { [weak self] _ in
            self?.mainWorkflowStateMachine = nil
        }

        print("current state: \(String(describing: signinStateMachine?.state.identifier))")
    }

    @IBAction func didTapListingPageButton(_ sender: Any) {

        // block the user to go to list until sign in, since mainWorkflowStateMachine will not exist until the user signed in
        mainWorkflowStateMachine?.transition(to: .list, completion: {

        })
    }

    @IBAction func didTapSignInButton(_ sender: Any) {
        // logout -> landing is blocked at compiling stage
        //signinStateMachine.transition(to: .landing) {}

        if signinStateMachine?.state.identifier == .login {
            signinStateMachine?.transition(to: .logout, completion: {
                signInButton.setTitle("Sign In", for: .normal)
                messageLabel.text = LOGOUT_MESSAGE
            })
        } else {
            signinStateMachine?.transition(to: .login, completion: {
                signInButton.setTitle("Sign Out", for: .normal)
                messageLabel.text = LOGIN_MESSAGE
            })
        }
    }

}

enum MainWorkflowState: StateIdentifier {
    case landing
    case list
    case detail
}

enum SignInState: StateIdentifier {
    case logout
    case login
    case error
}
