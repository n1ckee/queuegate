//
//  LoginController.swift
//  junction-queue
//
//  Created by Dmitry Latnikov on 11/24/17.
//  Copyright © 2017 Dmitry Latnikov. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
	
	var db: Firestore!
	
	let blueColor = UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1)
	let violetColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
	
	let inputsContainerView: UIView = {
		let containerView = UIView()
		containerView.backgroundColor = UIColor.white
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.layer.cornerRadius = 5
		containerView.layer.masksToBounds = true
		return containerView
	}()
	
	let loginRegisterButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
		button.setTitle("Login", for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitleColor(UIColor.white, for: .normal)
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		
		button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
		
		return button
	}()
	
	
	@objc private func handleLoginRegister() {
		if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
			onLogin()
		} else {
			onRegister()
		}
	}
	
	private func onLogin() {
		guard let email = emailTextField.text, let password = passwordTextField.text else {
			print("Form is not valid")
			return
		}
		
		Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
			if let error = error {
				self.displayAlert(title: "Ooooops", message: "Failed to login")
				print("Failed to login: \(error)")
				return
			}
			
			if let user = user {
				let db = Firestore.firestore()
				
				let docRef = db.collection("Users").document(user.uid)
				
				docRef.getDocument { (document, error) in
					if let error = error {
						print("Failed to fetch user by id: \(error.localizedDescription)")
						self.displayAlert(title: "Ooooops", message: "Failed to login")
						return
					}
					
					guard let document = document else {
						FirebaseCrashMessage("Failed to retrieve user document")
						fatalError()
					}
					
					if let userObject = User(dictionary: document.data()) {
						AuthenticationService.authenticate(userUid: user.uid, name: userObject.name, email: email, organizationId: userObject.organizationId)
						self.presentMainController()
					} else {
						FirebaseCrashMessage("Failed to create User object")
						fatalError()
					}
				}
			} else {
				print("Failed to get user object")
				return
			}
			
		}
	}
	
	func presentMainController() {
		OperationQueue.main.addOperation {
//			let listTicketsController = ListTicketsController()
//			let navController = UINavigationController(rootViewController: listTicketsController)
//			UIApplication.shared.keyWindow?.rootViewController = navController
		}
	}
	
	func onRegister() {
		guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
			print("Form is not valid")
			return
		}
		
		Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
			if let error = error {
				FirebaseCrashMessage("Error creating user: \(error.localizedDescription)")
				self.displayAlert(title: "Failed to create user", message: error.localizedDescription)
				return
			}
			
			// todo: remove hardcoded values
			let newUser = User(name: name, email: email, cardNumber: "0000111122223333", organizationId: "B0xrBdOyJDEEcdCjSTOO")
			
			guard let user = user else {
				print("Failed to create user")
				return
			}
			
			self.db.collection("Users").document(user.uid).setData(newUser.dictionary)
		}
	}
	
	let nameTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Name"
		textField.autocapitalizationType = .none
		textField.autocorrectionType = .no
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	let nameSeparatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let emailTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Email"
		textField.keyboardType = .emailAddress
		textField.autocapitalizationType = .none
		textField.autocorrectionType = .no
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	let emailSeparatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let passwordTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Password"
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.isSecureTextEntry = true
		return textField
	}()
	
	let logoImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "ic_security")
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	let loginRegisterSegmentedControl: UISegmentedControl = {
		let sc = UISegmentedControl(items: ["Login", "Register"])
		sc.translatesAutoresizingMaskIntoConstraints = false
		sc.tintColor = UIColor.white
		sc.selectedSegmentIndex = 0
		
		sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
		
		return sc
	}()
	
	@objc private func handleLoginRegisterChange() {
		let selectedIndex = loginRegisterSegmentedControl.selectedSegmentIndex
		let title = loginRegisterSegmentedControl.titleForSegment(at: selectedIndex)
		loginRegisterButton.setTitle(title, for: .normal)
		
		inputsContainerViewHeightAnchor?.constant = selectedIndex == 0 ? 100 : 150
		nameTextFieldHeightAnchor?.isActive = false
		nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: selectedIndex == 0 ? 0 : 1/3)
		nameTextFieldHeightAnchor?.isActive = true
		
		emailTextFieldHeightAnchor?.isActive = false
		emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: selectedIndex == 0 ? 1/2 : 1/3)
		emailTextFieldHeightAnchor?.isActive = true
		
		passwordTextFieldHeightAnchor?.isActive = false
		passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: selectedIndex == 0 ? 1/2 : 1/3)
		passwordTextFieldHeightAnchor?.isActive = true
	}
	
	var inputsContainerViewHeightAnchor: NSLayoutConstraint?
	var nameTextFieldHeightAnchor: NSLayoutConstraint?
	var emailTextFieldHeightAnchor: NSLayoutConstraint?
	var passwordTextFieldHeightAnchor: NSLayoutConstraint?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = blueColor
		
		view.addSubview(inputsContainerView)
		view.addSubview(loginRegisterButton)
		view.addSubview(logoImageView)
		view.addSubview(loginRegisterSegmentedControl)
		setupInputsViewContainer()
		setupLoginRegisterButton()
		setupLogoImageView()
		setupLoginRegisterSegmentedControl()
		
		// todo: remove
		emailTextField.text = "admin@gmail.com"
		passwordTextField.text = "Test123!"
		
		db = Firestore.firestore()
	}
	
	private func setupInputsViewContainer() {
		inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
		
		inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 100)
		inputsContainerViewHeightAnchor?.isActive = true
		
		inputsContainerView.addSubview(nameTextField)
		inputsContainerView.addSubview(nameSeparatorView)
		inputsContainerView.addSubview(emailTextField)
		inputsContainerView.addSubview(emailSeparatorView)
		inputsContainerView.addSubview(passwordTextField)
		
		nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
		nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
		nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
		nameTextFieldHeightAnchor?.isActive = true
		nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
		nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
		nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
		emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
		emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
		emailTextFieldHeightAnchor?.isActive = true
		emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
		emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
		emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
		passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
		passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
		passwordTextFieldHeightAnchor?.isActive = true
	}
	
	private func setupLoginRegisterButton() {
		loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
		loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}
	
	private func setupLogoImageView() {
		logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		logoImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
		logoImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
		logoImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
	}
	
	private func setupLoginRegisterSegmentedControl() {
		loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
		loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
	}
	
	let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
	
	func addActivityIndicator() {
		activityIndicator.center = view.center
		activityIndicator.hidesWhenStopped = false
		activityIndicator.startAnimating()
		view.addSubview(activityIndicator)
	}
	
	func removeActivityIndicator() {
		DispatchQueue.main.async {
			self.activityIndicator.stopAnimating()
			self.activityIndicator.removeFromSuperview()
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
}

