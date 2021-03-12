//
//  TextFieldValidationType.swift
//  TextFieldValidation
//
//  Created by Brendon Bitencourt Braga on 2021-03-07.
//

import Foundation

enum TextFieldValidationType {
    case email
    case required
    case maxCharacters(num: Int)
    case customRegex(regex: String, key: String)
    
    func validate(text: String?) -> TextFieldValidationType? {
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
    
    func getMessageModel(_ locale: String) -> TextFieldValidationMessages? {
        switch self {
            case .email:
                return self.getInfoFromPlist(locale, key: "email")
            case .required:
                return self.getInfoFromPlist(locale, key: "required")
            case .maxCharacters(num: _):
                return self.getInfoFromPlist(locale, key: "maxCharacters")
            case .customRegex(regex: _, key: let key):
                return self.getInfoFromPlist(locale, key: key)
        }
    }
    
    private func getInfoFromPlist(_ locale: String, key: String) -> TextFieldValidationMessages? {
        guard
            let path = Bundle.main.path(forResource: "Validations", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        else { return nil }
        
        do {
            let preferences = try PropertyListDecoder().decode([String:[String:TextFieldValidationMessages]].self, from: xml)
            return preferences[locale]?[key]
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
