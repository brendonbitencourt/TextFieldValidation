//
//  TextFieldValidation.swift
//  TextFieldValidation
//
//  Created by Brendon Bitencourt Braga on 2021-02-16.
//

import Foundation
import UIKit

class TextFieldValidation {
    
    weak var delegate: TextFieldValidationDelegate?
    private var validationsModel = [TextFieldValidationModel]()
    private var locale = "en-US"
    
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
    
    public func setLocale(_ locale: String) {
        self.locale = locale
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
                if let errorType = type.validate(text: textInput) {
                    let messageModel = errorType.getMessageModel(locale)
                    let error = TextFieldValidationError(message: messageModel?.message, shortMessage: messageModel?.shortMessage, type: errorType)
                    listErrors.append(error)
                }
            })
        }
        
        return listErrors
    }
}
