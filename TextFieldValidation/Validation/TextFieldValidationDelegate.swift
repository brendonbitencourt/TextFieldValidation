//
//  TextFieldValidationDelegate.swift
//  TextFieldValidation
//
//  Created by Brendon Bitencourt Braga on 2021-03-07.
//

import Foundation
import UIKit

protocol TextFieldValidationDelegate: class {
    func validationResult(textField: UITextField, error: TextFieldValidationError?) -> Void
    func validationStatus(isValid: Bool) -> Void
}
