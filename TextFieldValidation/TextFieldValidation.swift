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
            case .maxCharacters(num: _):
                return self.getInfoFromPlist(key: "maxCharacters")
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
        
        let error = TextFieldValidationType.email
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
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
