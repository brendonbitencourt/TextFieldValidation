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
    case required
    case maxCharacters(num: Int)
    case customRegex(regex: String, key: String)
    
    func validate(text: String?) -> TextFieldValidationError? {
        switch self {
            case .email:
                return TextFieldValidationFunctions.email(text)
            case .required:
                return TextFieldValidationFunctions.required(text)
            case .maxCharacters(num: let num):
                return TextFieldValidationFunctions.maxCharacters(text, num)
            case .customRegex(regex: let regex, key: let key):
                return TextFieldValidationFunctions.customRegex(text, regex, key)
        }
    }
    
    func getMessage() -> String? {
        return self.getMessageModel()?.message
    }
    
    func getShortMessage() -> String? {
        return self.getMessageModel()?.shortMessage
    }
    
    private func getMessageModel() -> TextFieldValidationMessages? {
        switch self {
            case .email:
                return self.getInfoFromPlist(key: "email")
            case .required:
                return self.getInfoFromPlist(key: "required")
            case .maxCharacters(num: _):
                return self.getInfoFromPlist(key: "maxCharacters")
            case .customRegex(regex: _, key: let key):
                return self.getInfoFromPlist(key: key)
        }
    }
    
    private func getInfoFromPlist(key: String) -> TextFieldValidationMessages? {
        guard
            let path = Bundle.main.path(forResource: "Validations", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        else { return nil }
        
        do {
            let preferences = try PropertyListDecoder().decode([String:TextFieldValidationMessages].self, from: xml)
            return preferences[key]
        } catch {
            print(error.localizedDescription)
            return nil
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

struct TextFieldValidationMessages: Codable {
    let message: String?
    let shortMessage: String?
}

//MARK: - Delegate
protocol TextFieldValidationDelegate: class {
    func validationResult(textField: UITextField, error: TextFieldValidationError?) -> Void
    func validationStatus(isValid: Bool) -> Void
}

//MARK: - TextFieldValidation Class
class TextFieldValidation {
    
    weak var delegate: TextFieldValidationDelegate?
    private var validationsModel = [TextFieldValidationModel]()
    
    init() {}
    
    //MARK: Public Functions
    public func addTextField(_ textField: UITextField, validations: [TextFieldValidationType]?) {
        let model = TextFieldValidationModel(textField: textField, validations: validations)
        validationsModel.append(model)
        model.textField?.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingChanged)
    }
    
    public func updateStatus() {
        var hasError: Bool = false
        
        for validationModel in validationsModel {
            let listErros = validateTextField(validationModel)
            if listErros.count > 0 {
                hasError = true
                break
            }
        }
        
        self.delegate?.validationStatus(isValid: !hasError)
    }
    
    //MARK: Private Functions
    @objc private func editingDidBegin(_ textField: UITextField) {
        let validationModel = validationsModel.first(where: { (textFieldValidationModel) -> Bool in
            return textFieldValidationModel.textField == textField
        })
        
        let listErrors = validateTextField(validationModel)
        
        self.delegate?.validationResult(textField: textField, error: listErrors.last)
        self.delegate?.validationStatus(isValid: listErrors.count == 0)
    }
    
    private func validateTextField(_ validationModel: TextFieldValidationModel?) -> [TextFieldValidationError] {
        var listErrors = [TextFieldValidationError]()
        
        if let validationModel = validationModel {
            let textInput = validationModel.textField?.text
            validationModel.validations?.forEach({ (type) in
                if let error = type.validate(text: textInput) {
                    listErrors.append(error)
                }
            })
        }
        
        return listErrors
    }
}

//MARK: - TextFieldValidationFunctions Class
class TextFieldValidationFunctions {
    static func email(_ text: String?) -> TextFieldValidationError? {
        
        let error = TextFieldValidationType.email
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid {
            return TextFieldValidationError(message: error.getMessage(), shortMessage: error.getShortMessage(), type: error)
        }
        
        return nil
    }
    
    static func required(_ text: String?) -> TextFieldValidationError? {
        
        let error = TextFieldValidationType.required
        let regEx = "^.{1,}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid {
            return TextFieldValidationError(message: error.getMessage(), shortMessage: error.getShortMessage(), type: error)
        }
        
        return nil
    }
    
    static func maxCharacters(_ text: String?, _ number: Int) -> TextFieldValidationError? {
        
        let error = TextFieldValidationType.maxCharacters(num: number)
        let regEx = "^.{0,\(String(number))}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid {
            return TextFieldValidationError(message: error.getMessage(), shortMessage: error.getShortMessage(), type: error)
        }
        
        return nil
    }
    
    static func customRegex(_ text: String?, _ regex: String, _ key: String) -> TextFieldValidationError? {
        
        let error = TextFieldValidationType.customRegex(regex: regex, key: key)
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: text)
        
        if !isValid {
            return TextFieldValidationError(message: error.getMessage(), shortMessage: error.getShortMessage(), type: error)
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
