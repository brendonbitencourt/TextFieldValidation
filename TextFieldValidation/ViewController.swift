//
//  ViewController.swift
//  TextFieldValidation
//
//  Created by Brendon Bitencourt Braga on 2021-02-16.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var nameTextField: BTextField!
    @IBOutlet weak var nameTextFieldErrorLabel: UILabel!
    @IBOutlet weak var emailTextField: BTextField!
    @IBOutlet weak var emailTextFieldErrorLabel: UILabel!
    @IBOutlet weak var enterButton: UIButton!
    
    //MARK: - Variables
    let validations = TextFieldValidation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        validations.delegate = self
        validations.addTextField(nameTextField, validations: [.maxCharacters(num: 5), .required])
        validations.addTextField(emailTextField, validations: [.email, .required])
        // Validate all Textfields
        validations.updateStatus()
    }
    
    //MARK: - Actions
    @IBAction func enterClicked(_ sender: Any) {
        print("Button Clicked")
    }
}

// MARK: - TextFieldValidationDelegate
extension ViewController: TextFieldValidationDelegate {
    
    func validationStatus(isValid: Bool) {
        self.enterButton.isEnabled = isValid
    }
    
    func validationResult(textField: UITextField, error: TextFieldValidationError?) -> Void {
        switch textField {
            case nameTextField:
                self.nameTextFieldErrorLabel.text = ((error?.message) != nil) ? error?.message : ""
            case emailTextField:
                self.emailTextFieldErrorLabel.text = ((error?.message) != nil) ? error?.message : ""
            default:
                return
        }
    }
}
