//
//  ViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 2/28/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
//This enum captures the changes of the state from creating a new user or an existing user
enum AccountState {
  case existingUser
  case newUser
}

class LoginViewController: UIViewController {
  
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var accountStateMessageLabel: UILabel!
  @IBOutlet weak var accountStateButton: UIButton!
  
  private var accountState: AccountState = .existingUser
  //you can do a singleton but not now cause we might do a delegation on it
  private var authSession = AuthenticationSession()
private var databaseService = DatabaseService()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    clearErrorLabel()
  }
  
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    print("login button pressed")
           //we want to make sure the 2 fields are not empty
    guard let email = emailTextField.text,
      !email.isEmpty,
      let password = passwordTextField.text,
      !password.isEmpty else {
        print("missing fields")
        return
    }
    continueLoginFlow(email: email, password: password)
  }
  
  private func continueLoginFlow(email: String, password: String) {
    if accountState == .existingUser {
      authSession.signExistingUser(email: email, password: password) { [weak self] (result) in
        switch result {
        case .failure(let error):
          DispatchQueue.main.async {
              //it will be a full out readable decription of the error
       
            self?.errorLabel.text = "\(error.localizedDescription)"
            self?.errorLabel.textColor = .systemRed
          }
        case .success:
          DispatchQueue.main.async {
                  //MARK: 11:46ama
               self?.errorLabel.text = "Welcome Back user "
            self?.navigateToMainView()
          }
        }
      }
    } else {
      authSession.createNewUser(email: email, password: password) { [weak self] (result) in
        switch result {
        case .failure(let error):
          DispatchQueue.main.async {
              //it will be a full out readable decription of the error
            self?.errorLabel.text = "\(error.localizedDescription)"
            self?.errorLabel.textColor = .systemRed
          }
        case .success(let authDataResult):
            //create a database user only from a new authenticated account
            self?.createDatabaseUser(authDataResult: authDataResult)
        }
      }
    }
  }
    private func createDatabaseUser(authDataResult: AuthDataResult) {
        databaseService.createDatabaseUser(authDataResult: authDataResult) { [weak self] (result) in
            switch result{
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Account error", message: error.localizedDescription)
                }
            case .success:
                DispatchQueue.main.async {
                    self?.navigateToMainView()
                }
            }
        }
    }
    
  private func navigateToMainView() {
    UIViewController.showViewController(storyBoardName: "MainView", viewControllerId: "MainTabBarController")
  }
  //NOW WE GET A COMPILER ERROR: Firebase-Demo[17034:798727] 6.18.0 - [Firebase/Analytics][I-ACS031025] Analytics screen reporting is enabled. Call +[FIRAnalytics setScreenName:setScreenClass:] to set the screen name or override the default screen class name. To disable screen reporting, set the flag FirebaseScreenReportingEnabled to NO (boolean) in the Info.plist
   
   //So we go to the firebase website into Authentication look at notes
  private func clearErrorLabel() {
    errorLabel.text = ""
  }
 
     //MARK: 11:35am
  @IBAction func toggleAccountState(_ sender: UIButton) {
      // change the account login state if it was previously existing
    accountState = accountState == .existingUser ? .newUser : .existingUser
    
    // animation duration
    let duration: TimeInterval = 1.0
    
    if accountState == .existingUser {
      UIView.transition(with: containerView, duration: duration, options: [.transitionFlipFromRight], animations: {
        self.loginButton.setTitle("Login", for: .normal)
        self.accountStateMessageLabel.text = "Don't have an account ? Click"
        self.accountStateButton.setTitle("SIGNUP", for: .normal)
      }, completion: nil)
    } else {
      UIView.transition(with: containerView, duration: duration, options: [.transitionFlipFromLeft], animations: {
        self.loginButton.setTitle("Sign Up", for: .normal)
        self.accountStateMessageLabel.text = "Already have an account ?"
        self.accountStateButton.setTitle("LOGIN", for: .normal)
      }, completion: nil)
    }
  }

}

