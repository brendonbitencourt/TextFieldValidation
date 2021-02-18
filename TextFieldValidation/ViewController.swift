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
    
    //MARK: - Variables
    let validations = TextFieldValidation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        validations.delegate = self
        validations.addTextField(nameTextField, validations: [.customRegex(regex: "^\\D+$", key: "onlyLetters"), .maxCharacters(num: 5)])
        validations.addTextField(emailTextField, validations: [.email])
    }
}

// MARK: - TextFieldValidationDelegate
extension ViewController: TextFieldValidationDelegate {
    
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
