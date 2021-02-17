//
//  TextFieldValidation.swift
//  TextFieldValidation
//
//  Created by Brendon Bitencourt Braga on 2021-02-16.
//

import Foundation
import UIKit

//MARK: - Enuns
enum TextFieldValidationType {
    case email
    case maxCharacters(num: Int)
    
    func validate(text: String?) -> TextFieldValidationError? {
        switch self {
            case .email:
                return TextFieldValidationFunctions.email(text)
            case .maxCharacters(num: let num):
                return TextFieldValidationFunctions.maxCharacters(text, num)
        }
    }
}

//MARK: - Model
struct TextFieldValidationError {
    let message: String?
    let shortMessage: String?
    let type: TextFieldValidationType
}

struct TextFieldValidationModel {
    let textField: UITextField?
    let validations: [TextFieldValidationType]?
}

//MARK: - Delegate
protocol TextFieldValidationDelegate: class {
    func validationResult(textField: UITextField, error: TextFieldValidationError?) -> Void
}

//MARK: - TextFieldValidation Class
class TextFieldValidation {
    
    weak var delegate: TextFieldValidationDelegate?
    private var validationsModel = [TextFieldValidationModel]()
    
    init() {}
    
    //MARK: Public Functions
    public func addTextField(_ textField: UITextField, validations: [TextFieldValidationType]?, controlEvent: UIControl.Event =  .editingChanged) {
        let model = TextFieldValidationModel(textField: textField, validations: validations)
        validationsModel.append(model)
        model.textField?.addTarget(self, action: #selector(editingDidBegin(_:)), for: controlEvent)
    }
    
    //MARK: Private Functions
    @objc private func editingDidBegin(_ textField: UITextField) {
        let validationModel = validationsModel.first(where: { (textFieldValidationModel) -> Bool in
            return textFieldValidationModel.textField == textField
        })
        
        if let textField = validationModel?.textField {
            let textInput = validationModel?.textField?.text
            
            var error: TextFieldValidationError? = nil
            validationModel?.validations?.forEach({ (type) in
                error = type.validate(text: textInput)
            })
            
            self.delegate?.validationResult(textField: textField, error: error)
        }
    }
}

//MARK: - TextFieldValidationFunctions Class
class TextFieldValidationFunctions {
    static func email(_ text: String?) -> TextFieldValidationError? {
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid {
            return TextFieldValidationError(message: "Email inválido", shortMessage: "Inválido", type: .email)
        }
        
        return nil
    }
    
    static func maxCharacters(_ text: String?, _ num: Int) -> TextFieldValidationError? {
        
        let regEx = "^.{0,\(String(num))}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid {
            return TextFieldValidationError(message: "Campo inválido", shortMessage: "Inválido", type: .email)
        }
        
        return nil
    }
}

//MARK: - BTextField Class
class BTextField: UITextField {
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
